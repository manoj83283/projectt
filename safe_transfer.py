#!/usr/bin/env python3
"""Safe, repeatable, content-deduplicating file transfer utility.

Copies files from Source A to Destination B using FORMAT/YEAR folders. Exact
content duplicates are routed to Destination C, while files that fail validation
are routed to the corrupted-files tree. Final files are published atomically
only after a SHA-256 verification pass.
"""

from __future__ import annotations

import argparse
import bz2
import csv
import datetime as dt
import gzip
import hashlib
import json
import logging
import lzma
import os
import re
import shutil
import signal
import sqlite3
import subprocess
import sys
import tarfile
import tempfile
import threading
import uuid
import zipfile
from dataclasses import asdict, dataclass, field
from pathlib import Path
from typing import Iterable, Optional
from xml.etree import ElementTree

try:  # Optional packages add deeper format-aware validation; built-in fallbacks remain usable.
    import filetype
except ImportError:
    filetype = None
try:
    from PIL import Image, UnidentifiedImageError
except ImportError:
    Image = None
    class UnidentifiedImageError(Exception):
        pass
try:
    from mutagen import File as MutagenFile
except ImportError:
    MutagenFile = None
try:
    from pypdf import PdfReader
except ImportError:
    PdfReader = None

APP_VERSION = "1.0.0"
CHUNK_SIZE = 8 * 1024 * 1024
MEDIA_FORMATS = {
    "MP4", "M4V", "MOV", "AVI", "MKV", "WEBM", "MPEG", "MPG", "WMV",
    "FLV", "3GP", "MP3", "M4A", "AAC", "FLAC", "WAV", "OGG", "WMA",
}
IMAGE_FORMATS = {
    "JPG", "JPEG", "PNG", "GIF", "BMP", "TIFF", "TIF", "WEBP", "HEIC",
    "HEIF", "ICO", "PSD", "AVIF",
}
WINDOWS_RESERVED = {
    "CON", "PRN", "AUX", "NUL", *(f"COM{i}" for i in range(1, 10)),
    *(f"LPT{i}" for i in range(1, 10)),
}
INVALID_FILENAME = re.compile(r'[<>:"/\\|?*\x00-\x1f]')
OWN_TEMP_FILE = re.compile(r"^\..+\.[0-9a-f]{32}\.part$")
YEAR_RE = re.compile(r"(?<!\d)(19\d{2}|20\d{2}|2100)(?!\d)")
DATE_RE = re.compile(r"(?<!\d)(19\d{2}|20\d{2}|2100)[-_./]?(?:0[1-9]|1[0-2])[-_./]?(?:0[1-9]|[12]\d|3[01])(?!\d)")
_stop_requested = threading.Event()


@dataclass
class Inspection:
    source: str
    size: int = 0
    sha256: str = ""
    format: str = "UNKNOWN"
    extension: str = ""
    signature_extension: str = ""
    signature_mismatch: bool = False
    year: str = "UNKNOWN"
    year_source: str = "unknown"
    valid: bool = False
    validation: str = "not inspected"
    route: str = ""
    planned_destination: str = ""
    status: str = "PLANNED"
    error: str = ""


@dataclass
class Summary:
    version: str = APP_VERSION
    run_id: str = ""
    started_at: str = ""
    finished_at: str = ""
    source_files: int = 0
    source_bytes: int = 0
    destination_files_indexed: int = 0
    destination_hash_errors: int = 0
    planned_unique: int = 0
    planned_duplicates: int = 0
    planned_corrupt: int = 0
    copied_unique: int = 0
    copied_duplicates: int = 0
    copied_corrupt: int = 0
    already_present: int = 0
    skipped: int = 0
    failed: int = 0
    bytes_copied: int = 0
    interrupted: bool = False
    dry_run: bool = False
    capacity: list[dict] = field(default_factory=list)


def iso_now() -> str:
    return dt.datetime.now(dt.timezone.utc).astimezone().isoformat(timespec="seconds")


def request_stop(signum, _frame) -> None:
    _stop_requested.set()
    logging.warning("Interruption requested (signal %s); finishing safely.", signum)


def normalized_path(raw: str) -> Path:
    return Path(os.path.expandvars(os.path.expanduser(raw.strip().strip('"')))).resolve()


def path_is_within(child: Path, parent: Path) -> bool:
    try:
        child.resolve().relative_to(parent.resolve())
        return True
    except ValueError:
        return False


def validate_path_layout(source: Path, destination: Path, duplicates: Path, corrupted: Path) -> None:
    if not source.is_dir():
        raise ValueError(f"Source A does not exist or is not a directory: {source}")
    for label, path in (("Destination B", destination), ("Destination C", duplicates), ("corrupted-files", corrupted)):
        if path == source or path_is_within(path, source) or path_is_within(source, path):
            raise ValueError(f"{label} must not overlap Source A: {path}")
    if destination == duplicates or path_is_within(destination, duplicates) or path_is_within(duplicates, destination):
        raise ValueError("Destination B and Destination C must be separate, non-nested locations.")
    if corrupted == destination or path_is_within(corrupted, destination):
        raise ValueError("The corrupted-files folder must not be inside Destination B.")


def safe_filename(name: str) -> str:
    name = INVALID_FILENAME.sub("_", name).strip().rstrip(". ")
    if not name:
        name = "unnamed"
    p = Path(name)
    if p.stem.upper() in WINDOWS_RESERVED:
        name = f"_{name}"
    # Stay below common Windows path-component limits and preserve extension.
    if len(name) > 180:
        suffix = p.suffix[:20]
        stem_limit = max(1, 180 - len(suffix))
        name = p.stem[:stem_limit] + suffix
    return name


def iter_files(root: Path) -> Iterable[Path]:
    for current, dirs, files in os.walk(root, followlinks=False):
        dirs[:] = sorted(d for d in dirs if not (Path(current) / d).is_symlink())
        for name in sorted(files):
            path = Path(current) / name
            if path.is_symlink():
                logging.warning("Skipping symbolic link: %s", path)
                continue
            if path.is_file():
                yield path


def hash_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb", buffering=0) as handle:
        while True:
            if _stop_requested.is_set():
                raise InterruptedError("Interrupted while hashing")
            block = handle.read(CHUNK_SIZE)
            if not block:
                break
            digest.update(block)
    return digest.hexdigest()


def built_in_signature(path: Path) -> str:
    """Return a conservative extension guess using common binary signatures."""
    try:
        with path.open("rb") as handle:
            head = handle.read(560)
    except OSError:
        return ""
    if head.startswith(b"\xff\xd8\xff"): return "jpg"
    if head.startswith(b"\x89PNG\r\n\x1a\n"): return "png"
    if head.startswith((b"GIF87a", b"GIF89a")): return "gif"
    if head.startswith(b"BM"): return "bmp"
    if head.startswith((b"II*\x00", b"MM\x00*")): return "tif"
    if head.startswith(b"%PDF-"): return "pdf"
    if head.startswith(b"SQLite format 3\x00"): return "sqlite"
    if head.startswith(b"7z\xbc\xaf\x27\x1c"): return "7z"
    if head.startswith(b"Rar!\x1a\x07"): return "rar"
    if head.startswith(b"\x1f\x8b"): return "gz"
    if head.startswith(b"BZh"): return "bz2"
    if head.startswith(b"\xfd7zXZ\x00"): return "xz"
    if head.startswith(b"OggS"): return "ogg"
    if head.startswith(b"fLaC"): return "flac"
    if head.startswith(b"ID3") or head[:2] in {b"\xff\xfb", b"\xff\xf3", b"\xff\xf2"}: return "mp3"
    if head.startswith(b"\x1aE\xdf\xa3"): return "mkv"
    if head.startswith(b"MZ"): return "exe"
    if head.startswith(b"\x7fELF"): return "elf"
    if len(head) >= 12 and head[:4] == b"RIFF":
        if head[8:12] == b"WEBP": return "webp"
        if head[8:12] == b"WAVE": return "wav"
        if head[8:12] == b"AVI ": return "avi"
    if len(head) >= 12 and head[4:8] == b"ftyp":
        brand = head[8:12]
        return "mov" if brand in {b"qt  ", b"mqt "} else "mp4"
    if head.startswith((b"PK\x03\x04", b"PK\x05\x06", b"PK\x07\x08")):
        try:
            with zipfile.ZipFile(path) as archive:
                names = set(archive.namelist())
            if "word/document.xml" in names: return "docx"
            if "xl/workbook.xml" in names: return "xlsx"
            if "ppt/presentation.xml" in names: return "pptx"
            if "META-INF/container.xml" in names: return "epub"
        except Exception:
            pass
        return "zip"
    return ""


def detect_format(path: Path) -> tuple[str, str, str, bool]:
    extension = path.suffix.lower().lstrip(".")
    signature_extension = ""
    if filetype is not None:
        try:
            kind = filetype.guess(str(path))
            if kind:
                signature_extension = (kind.extension or "").lower()
        except (OSError, ValueError):
            pass
    signature_extension = built_in_signature(path) or signature_extension
    chosen = signature_extension or extension or "NO_EXTENSION"
    aliases = {"jpeg": "jpg", "tiff": "tif"}
    chosen = aliases.get(chosen, chosen)
    mismatch = bool(signature_extension and extension and aliases.get(extension, extension) != aliases.get(signature_extension, signature_extension))
    return chosen.upper(), extension, signature_extension, mismatch


def year_from_value(value) -> Optional[str]:
    if isinstance(value, (dt.date, dt.datetime)):
        return str(value.year) if 1900 <= value.year <= 2100 else None
    text = str(value or "")
    match = YEAR_RE.search(text)
    return match.group(1) if match else None


def image_year(path: Path) -> Optional[str]:
    if Image is None:
        return None
    try:
        with Image.open(path) as img:
            exif = img.getexif()
            for key in (36867, 36868, 306):  # DateTimeOriginal, DateTimeDigitized, DateTime
                value = exif.get(key)
                year = year_from_value(value)
                if year:
                    return year
    except Exception:
        return None
    return None


def pdf_year(path: Path) -> Optional[str]:
    if PdfReader is None:
        return None
    try:
        reader = PdfReader(str(path), strict=False)
        metadata = reader.metadata
        if metadata:
            for value in (getattr(metadata, "creation_date", None), getattr(metadata, "modification_date", None), metadata.get("/CreationDate"), metadata.get("/ModDate")):
                year = year_from_value(value)
                if year:
                    return year
    except Exception:
        return None
    return None


def office_year(path: Path) -> Optional[str]:
    try:
        with zipfile.ZipFile(path) as archive:
            if "docProps/core.xml" not in archive.namelist():
                return None
            root = ElementTree.fromstring(archive.read("docProps/core.xml"))
            for tag in ("{http://purl.org/dc/terms/}created", "{http://purl.org/dc/terms/}modified"):
                node = root.find(tag)
                if node is not None:
                    year = year_from_value(node.text)
                    if year:
                        return year
    except Exception:
        return None
    return None


def media_year(path: Path) -> Optional[str]:
    if MutagenFile is None:
        return None
    try:
        media = MutagenFile(str(path), easy=True)
        tags = getattr(media, "tags", None)
        if not tags:
            return None
        for key in ("date", "year", "originaldate", "recordingdate", "©day"):
            values = tags.get(key)
            if values is None:
                continue
            if not isinstance(values, (list, tuple)):
                values = [values]
            for value in values:
                year = year_from_value(value)
                if year:
                    return year
    except Exception:
        return None
    return None


def infer_year(path: Path, fmt: str) -> tuple[str, str]:
    if fmt in IMAGE_FORMATS:
        year = image_year(path)
        if year:
            return year, "embedded image metadata"
    if fmt == "PDF":
        year = pdf_year(path)
        if year:
            return year, "PDF metadata"
    if fmt in {"DOCX", "XLSX", "PPTX", "ODT", "ODS", "ODP"}:
        year = office_year(path)
        if year:
            return year, "document metadata"
    if fmt in MEDIA_FORMATS:
        year = media_year(path)
        if year:
            return year, "media metadata"

    match = DATE_RE.search(path.name) or YEAR_RE.search(path.stem)
    if match:
        return match.group(1), "filename"
    for parent in path.parents:
        match = YEAR_RE.search(parent.name)
        if match:
            return match.group(1), "parent folder"
    try:
        return str(dt.datetime.fromtimestamp(path.stat().st_mtime).year), "file modified time"
    except (OSError, OverflowError, ValueError):
        return "UNKNOWN", "unknown"


def run_ffprobe(path: Path) -> tuple[bool, str]:
    command = ["ffprobe", "-v", "error", "-show_entries", "format=format_name,duration", "-of", "json", str(path)]
    try:
        result = subprocess.run(command, capture_output=True, text=True, timeout=120, check=False)
    except FileNotFoundError:
        return True, "signature/readability check only (ffprobe not installed)"
    except subprocess.TimeoutExpired:
        return False, "ffprobe timed out"
    if result.returncode != 0:
        detail = (result.stderr or "ffprobe rejected the file").strip().splitlines()[-1]
        return False, f"ffprobe: {detail[:300]}"
    return True, "ffprobe accepted media container"


def validate_file(path: Path, fmt: str, deep_media_check: bool) -> tuple[bool, str]:
    try:
        size = path.stat().st_size
        if size == 0:
            return False, "zero-byte file"
        with path.open("rb") as handle:
            if not handle.read(1):
                return False, "unreadable or empty file"
    except (OSError, PermissionError) as exc:
        return False, f"read error: {exc}"

    try:
        if fmt in IMAGE_FORMATS and Image is not None:
            with Image.open(path) as img:
                img.verify()
            return True, "image decoder verification passed"
        if fmt == "PDF":
            if PdfReader is not None:
                reader = PdfReader(str(path), strict=False)
                _ = len(reader.pages)
                return True, "PDF structure verification passed"
            with path.open("rb") as handle:
                if not handle.read(5).startswith(b"%PDF-"):
                    return False, "PDF header is missing"
                handle.seek(max(0, size - 65536))
                if b"%%EOF" not in handle.read():
                    return False, "PDF end marker is missing"
            return True, "basic PDF header/end-marker verification passed"
        if fmt in {"ZIP", "DOCX", "XLSX", "PPTX", "ODT", "ODS", "ODP", "EPUB", "JAR"}:
            with zipfile.ZipFile(path) as archive:
                bad_member = archive.testzip()
                if bad_member:
                    return False, f"ZIP CRC failed for member: {bad_member}"
            return True, "ZIP/container CRC verification passed"
        if fmt in {"GZ", "GZIP"}:
            with gzip.open(path, "rb") as handle:
                while handle.read(CHUNK_SIZE):
                    pass
            return True, "gzip stream verification passed"
        if fmt == "BZ2":
            with bz2.open(path, "rb") as handle:
                while handle.read(CHUNK_SIZE):
                    pass
            return True, "bzip2 stream verification passed"
        if fmt in {"XZ", "LZMA"}:
            with lzma.open(path, "rb") as handle:
                while handle.read(CHUNK_SIZE):
                    pass
            return True, "xz/lzma stream verification passed"
        if fmt in {"TAR", "TGZ", "TBZ", "TBZ2", "TXZ"}:
            with tarfile.open(path, "r:*") as archive:
                for member in archive:
                    if member.isfile():
                        extracted = archive.extractfile(member)
                        if extracted:
                            while extracted.read(CHUNK_SIZE):
                                pass
            return True, "tar archive verification passed"
        if fmt == "JSON":
            with path.open("r", encoding="utf-8-sig") as handle:
                json.load(handle)
            return True, "JSON parsing passed"
        if fmt in {"XML", "SVG"}:
            ElementTree.parse(path)
            return True, "XML parsing passed"
        if fmt in {"SQLITE", "SQLITE3", "DB"}:
            uri = path.resolve().as_uri() + "?mode=ro"
            with sqlite3.connect(uri, uri=True) as conn:
                result = conn.execute("PRAGMA quick_check").fetchone()
            if not result or result[0] != "ok":
                return False, f"SQLite quick_check failed: {result}"
            return True, "SQLite quick_check passed"
        if fmt in MEDIA_FORMATS and deep_media_check:
            return run_ffprobe(path)
        if fmt in MEDIA_FORMATS and MutagenFile is not None:
            # Mutagen understands many common audio and MP4 containers. If it does
            # not, signature + full SHA-256 read still provides a generic check.
            try:
                media = MutagenFile(str(path))
                if media is not None:
                    return True, "media container metadata parsed"
            except Exception as exc:
                return False, f"media parser rejected file: {exc}"
            return True, "signature/readability check passed; format has no bundled semantic validator"
    except (OSError, PermissionError, zipfile.BadZipFile, tarfile.TarError, EOFError, ValueError, ElementTree.ParseError, json.JSONDecodeError, UnidentifiedImageError) as exc:
        return False, f"validation failed: {exc}"
    except Exception as exc:
        return False, f"validator error: {type(exc).__name__}: {exc}"

    return True, "generic readability and full SHA-256 read passed"


def inspect_source(path: Path, deep_media_check: bool) -> Inspection:
    item = Inspection(source=str(path))
    try:
        item.size = path.stat().st_size
        item.format, item.extension, item.signature_extension, item.signature_mismatch = detect_format(path)
        item.year, item.year_source = infer_year(path, item.format)
        item.valid, item.validation = validate_file(path, item.format, deep_media_check)
        item.sha256 = hash_file(path)
    except InterruptedError:
        raise
    except Exception as exc:
        item.valid = False
        item.validation = f"inspection failed: {type(exc).__name__}: {exc}"
        item.error = item.validation
        try:
            item.size = path.stat().st_size
        except OSError:
            pass
    return item


def is_internal_destination_file(path: Path, destination: Path) -> bool:
    try:
        rel = path.relative_to(destination)
    except ValueError:
        return False
    return bool(rel.parts and rel.parts[0] == ".safe_transfer") or path.name.endswith(".part")


def cleanup_stale_temp_files(roots: Iterable[Path]) -> int:
    """Remove only temp files whose names match this tool's UUID pattern."""
    removed = 0
    visited: set[Path] = set()
    for root in roots:
        if root in visited or not root.exists():
            continue
        visited.add(root)
        for path in iter_files(root):
            if not OWN_TEMP_FILE.match(path.name):
                continue
            try:
                path.unlink()
                removed += 1
                logging.warning("Removed stale interrupted-copy temp file: %s", path)
            except OSError as exc:
                logging.warning("Could not remove stale temp file %s: %s", path, exc)
    return removed


def index_destination(destination: Path) -> tuple[dict[str, list[str]], int, int]:
    index: dict[str, list[str]] = {}
    count = errors = 0
    if not destination.exists():
        return index, count, errors
    logging.info("Indexing Destination B for exact SHA-256 duplicates: %s", destination)
    for path in iter_files(destination):
        if is_internal_destination_file(path, destination):
            continue
        try:
            digest = hash_file(path)
            index.setdefault(digest, []).append(str(path))
            count += 1
        except InterruptedError:
            raise
        except Exception as exc:
            errors += 1
            logging.error("Could not hash destination file %s: %s", path, exc)
    return index, count, errors


def choose_target(root: Path, item: Inspection, reserved: set[Path]) -> Path:
    directory = root / item.format / item.year
    filename = safe_filename(Path(item.source).name)
    base = directory / filename
    if not base.exists() and base not in reserved:
        reserved.add(base)
        return base
    try:
        if base not in reserved and item.sha256 and hash_file(base) == item.sha256:
            reserved.add(base)
            return base
    except Exception:
        pass
    p = Path(filename)
    candidate = directory / f"{p.stem}__{item.sha256[:10] or 'different'}{p.suffix}"
    serial = 2
    while candidate.exists() or candidate in reserved:
        try:
            if candidate not in reserved and item.sha256 and hash_file(candidate) == item.sha256:
                reserved.add(candidate)
                return candidate
        except Exception:
            pass
        candidate = directory / f"{p.stem}__{item.sha256[:10] or 'different'}__{serial}{p.suffix}"
        serial += 1
    reserved.add(candidate)
    return candidate


def nearest_existing(path: Path) -> Path:
    probe = path
    while not probe.exists() and probe != probe.parent:
        probe = probe.parent
    return probe


def volume_key(path: Path) -> tuple:
    existing = nearest_existing(path)
    try:
        stat = existing.stat()
        return (stat.st_dev, os.path.splitdrive(str(existing))[0].upper())
    except OSError:
        return (str(existing.anchor).upper(),)


def capacity_plan(items: list[Inspection], roots: dict[str, Path], reserve_bytes: int) -> list[dict]:
    grouped: dict[tuple, dict] = {}
    for item in items:
        if item.route not in roots:
            continue
        root = roots[item.route]
        key = volume_key(root)
        record = grouped.setdefault(key, {"paths": set(), "required_bytes": 0})
        record["paths"].add(str(root))
        required = max(0, item.size)
        target = Path(item.planned_destination)
        if target.exists() and item.sha256:
            try:
                if hash_file(target) == item.sha256:
                    required = 0
            except Exception:
                pass
        record["required_bytes"] += required
    reports = []
    for data in grouped.values():
        probe = nearest_existing(Path(next(iter(data["paths"]))))
        usage = shutil.disk_usage(probe)
        required = data["required_bytes"]
        safety_margin = max(reserve_bytes, int(required * 0.05))
        reports.append({
            "paths": sorted(data["paths"]),
            "required_bytes": required,
            "safety_margin_bytes": safety_margin,
            "free_bytes": usage.free,
            "sufficient": usage.free >= required + safety_margin,
        })
    return reports


def format_bytes(value: int) -> str:
    units = ["B", "KiB", "MiB", "GiB", "TiB"]
    amount = float(value)
    for unit in units:
        if amount < 1024 or unit == units[-1]:
            return f"{amount:.2f} {unit}"
        amount /= 1024
    return f"{value} B"


def ensure_free_space(target_dir: Path, needed: int, reserve_bytes: int) -> None:
    probe = nearest_existing(target_dir)
    free = shutil.disk_usage(probe).free
    if free < needed + reserve_bytes:
        raise OSError(
            f"Insufficient free space at {probe}: need {format_bytes(needed + reserve_bytes)}, "
            f"available {format_bytes(free)}"
        )


def copy_atomic_verified(source: Path, target: Path, expected_hash: str, reserve_bytes: int) -> tuple[str, int]:
    target.parent.mkdir(parents=True, exist_ok=True)
    if target.exists():
        try:
            if hash_file(target) == expected_hash:
                return "ALREADY_PRESENT", 0
        except Exception:
            pass
        raise FileExistsError(f"Refusing to overwrite different file: {target}")

    ensure_free_space(target.parent, source.stat().st_size, reserve_bytes)
    temp_path = target.parent / f".{target.name}.{uuid.uuid4().hex}.part"
    written = 0
    try:
        with source.open("rb", buffering=0) as src, temp_path.open("xb", buffering=0) as dst:
            while True:
                if _stop_requested.is_set():
                    raise InterruptedError("Interrupted during copy")
                block = src.read(CHUNK_SIZE)
                if not block:
                    break
                dst.write(block)
                written += len(block)
            dst.flush()
            os.fsync(dst.fileno())
        copied_hash = hash_file(temp_path)
        if copied_hash != expected_hash:
            raise IOError(f"Post-copy SHA-256 mismatch: expected {expected_hash}, got {copied_hash}")
        try:
            shutil.copystat(source, temp_path, follow_symlinks=False)
        except OSError as exc:
            logging.warning("Could not preserve all timestamps/attributes for %s: %s", source, exc)
        os.replace(temp_path, target)
        return "COPIED", written
    except BaseException:
        try:
            temp_path.unlink(missing_ok=True)
        except OSError:
            pass
        raise


def setup_logging(report_dir: Path, verbose: bool) -> None:
    report_dir.mkdir(parents=True, exist_ok=True)
    handlers = [logging.FileHandler(report_dir / "transfer.log", encoding="utf-8"), logging.StreamHandler()]
    logging.basicConfig(
        level=logging.DEBUG if verbose else logging.INFO,
        format="%(asctime)s %(levelname)s %(message)s",
        handlers=handlers,
        force=True,
    )


def write_reports(report_dir: Path, items: list[Inspection], summary: Summary, config: dict) -> None:
    report_dir.mkdir(parents=True, exist_ok=True)
    fields = list(Inspection.__dataclass_fields__.keys())
    with (report_dir / "files.csv").open("w", newline="", encoding="utf-8-sig") as handle:
        writer = csv.DictWriter(handle, fieldnames=fields)
        writer.writeheader()
        for item in items:
            writer.writerow(asdict(item))
    payload = asdict(summary)
    payload["configuration"] = config
    with (report_dir / "summary.json").open("w", encoding="utf-8") as handle:
        json.dump(payload, handle, indent=2, ensure_ascii=False)


def prompt_if_missing(args) -> None:
    print("\nSafe File Transfer - Source A to Destination B\n")
    if not args.source:
        args.source = input("Source A folder: ").strip()
    if not args.destination:
        args.destination = input("Destination B folder (unique files): ").strip()
    if not args.duplicates:
        args.duplicates = input("Destination C folder (duplicates): ").strip()
    if not args.corrupted:
        suggested = str(Path(os.path.expandvars(os.path.expanduser(args.duplicates.strip().strip('"')))) / "corrupted-files")
        entered = input(f"Corrupted-files folder [default: {suggested}]: ").strip()
        args.corrupted = entered or suggested


def parse_args(argv: Optional[list[str]] = None):
    parser = argparse.ArgumentParser(
        description="Copy Source A into FORMAT/YEAR folders, isolate duplicates and corrupt files, and verify every copy.",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    parser.add_argument("--source", help="Source A directory")
    parser.add_argument("--destination", help="Destination B directory for unique files")
    parser.add_argument("--duplicates", help="Destination C directory for exact duplicates")
    parser.add_argument("--corrupted", help="Directory for corrupt/unreadable files (default: Destination C/corrupted-files)")
    parser.add_argument("--report-dir", help="Custom report directory (default: Destination B/.safe_transfer/reports/<run>)")
    parser.add_argument("--dry-run", action="store_true", help="Inspect and plan without copying files")
    parser.add_argument("--allow-partial", action="store_true", help="Continue when the preflight capacity check is short; stop safely when per-file space is exhausted")
    parser.add_argument("--deep-media-check", action="store_true", help="Use ffprobe for media validation when ffprobe is installed")
    parser.add_argument("--reserve-mb", type=int, default=100, help="Free-space reserve maintained on each destination volume")
    parser.add_argument("--verbose", action="store_true", help="Enable verbose logs")
    parser.add_argument("--version", action="version", version=f"%(prog)s {APP_VERSION}")
    return parser.parse_args(argv)


def main(argv: Optional[list[str]] = None) -> int:
    args = parse_args(argv)
    prompt_if_missing(args)
    source = normalized_path(args.source)
    destination = normalized_path(args.destination)
    duplicates = normalized_path(args.duplicates)
    corrupted = normalized_path(args.corrupted or str(duplicates / "corrupted-files"))
    validate_path_layout(source, destination, duplicates, corrupted)

    destination.mkdir(parents=True, exist_ok=True)
    duplicates.mkdir(parents=True, exist_ok=True)
    corrupted.mkdir(parents=True, exist_ok=True)

    run_id = dt.datetime.now().strftime("%Y%m%d_%H%M%S") + "_" + uuid.uuid4().hex[:8]
    report_dir = normalized_path(args.report_dir) if args.report_dir else destination / ".safe_transfer" / "reports" / run_id
    setup_logging(report_dir, args.verbose)
    for signum in (getattr(signal, "SIGINT", None), getattr(signal, "SIGTERM", None)):
        if signum is not None:
            signal.signal(signum, request_stop)

    summary = Summary(run_id=run_id, started_at=iso_now(), dry_run=args.dry_run)
    reserve_bytes = max(0, args.reserve_mb) * 1024 * 1024
    config = {
        "source": str(source), "destination": str(destination), "duplicates": str(duplicates),
        "corrupted": str(corrupted), "report_dir": str(report_dir), "dry_run": args.dry_run,
        "allow_partial": args.allow_partial, "deep_media_check": args.deep_media_check,
        "reserve_mb": max(0, args.reserve_mb),
    }
    items: list[Inspection] = []

    try:
        logging.info("Run %s started", run_id)
        if not args.dry_run:
            removed_temps = cleanup_stale_temp_files((destination, duplicates, corrupted))
            if removed_temps:
                logging.info("Removed %d stale temporary file(s) from an earlier interrupted run.", removed_temps)
        destination_index, summary.destination_files_indexed, summary.destination_hash_errors = index_destination(destination)
        if summary.destination_hash_errors:
            raise RuntimeError(
                "Destination B contains files that could not be hashed. Fix permissions/read errors before running; "
                "continuing could allow an undetected duplicate."
            )

        source_seen: set[str] = set()
        logging.info("Inspecting Source A: %s", source)
        reserved_targets: set[Path] = set()
        for path in iter_files(source):
            if _stop_requested.is_set():
                raise InterruptedError("Interrupted during source inspection")
            item = inspect_source(path, args.deep_media_check)
            summary.source_files += 1
            summary.source_bytes += item.size
            if not item.valid:
                item.route = "corrupt"
                summary.planned_corrupt += 1
            elif item.sha256 in destination_index or item.sha256 in source_seen:
                item.route = "duplicate"
                summary.planned_duplicates += 1
            else:
                item.route = "unique"
                source_seen.add(item.sha256)
                summary.planned_unique += 1
            roots = {"unique": destination, "duplicate": duplicates, "corrupt": corrupted}
            item.planned_destination = str(choose_target(roots[item.route], item, reserved_targets))
            items.append(item)

        roots = {"unique": destination, "duplicate": duplicates, "corrupt": corrupted}
        summary.capacity = capacity_plan(items, roots, reserve_bytes)
        logging.info(
            "Plan: %d unique, %d duplicate, %d corrupt; source total %s",
            summary.planned_unique, summary.planned_duplicates, summary.planned_corrupt,
            format_bytes(summary.source_bytes),
        )
        insufficient = [entry for entry in summary.capacity if not entry["sufficient"]]
        for entry in summary.capacity:
            logging.info(
                "Capacity for %s: required %s + margin %s; free %s; sufficient=%s",
                ", ".join(entry["paths"]), format_bytes(entry["required_bytes"]),
                format_bytes(entry["safety_margin_bytes"]), format_bytes(entry["free_bytes"]),
                entry["sufficient"],
            )
        if insufficient and not args.allow_partial and not args.dry_run:
            for item in items:
                item.status = "NOT_COPIED_CAPACITY_PREFLIGHT"
            raise OSError("Preflight storage-capacity check failed. No source files were copied.")

        if args.dry_run:
            for item in items:
                item.status = "DRY_RUN"
            logging.info("Dry run complete; no files were copied.")
        else:
            for item in items:
                if _stop_requested.is_set():
                    raise InterruptedError("Interrupted before next file")
                target = Path(item.planned_destination)
                try:
                    status, copied_bytes = copy_atomic_verified(Path(item.source), target, item.sha256, reserve_bytes)
                    item.status = status
                    if status == "ALREADY_PRESENT":
                        summary.already_present += 1
                    elif item.route == "unique":
                        summary.copied_unique += 1
                    elif item.route == "duplicate":
                        summary.copied_duplicates += 1
                    else:
                        summary.copied_corrupt += 1
                    summary.bytes_copied += copied_bytes
                    logging.info("%s -> %s [%s/%s]", item.source, target, item.route, status)
                except InterruptedError:
                    item.status = "INTERRUPTED"
                    raise
                except Exception as exc:
                    item.status = "FAILED"
                    item.error = f"{type(exc).__name__}: {exc}"
                    summary.failed += 1
                    logging.error("Failed copying %s: %s", item.source, exc)
                    if isinstance(exc, OSError) and "Insufficient free space" in str(exc):
                        logging.error("Stopping safely because destination storage is low.")
                        break

    except InterruptedError as exc:
        summary.interrupted = True
        logging.warning("Run interrupted safely: %s", exc)
        for item in items:
            if item.status == "PLANNED":
                item.status = "NOT_COPIED_INTERRUPTED"
    except Exception as exc:
        logging.error("Run stopped: %s", exc)
        if not items:
            summary.failed += 1
        summary.finished_at = iso_now()
        write_reports(report_dir, items, summary, config)
        logging.info("Reports: %s", report_dir)
        print(f"\nFAILED: {exc}\nReports: {report_dir}", file=sys.stderr)
        return 4

    summary.finished_at = iso_now()
    write_reports(report_dir, items, summary, config)
    logging.info("Run finished. Reports: %s", report_dir)
    print("\nTransfer summary")
    print(f"  Unique copied:     {summary.copied_unique}")
    print(f"  Duplicates copied: {summary.copied_duplicates}")
    print(f"  Corrupt copied:    {summary.copied_corrupt}")
    print(f"  Already present:   {summary.already_present}")
    print(f"  Failed:            {summary.failed}")
    print(f"  Bytes copied:      {format_bytes(summary.bytes_copied)}")
    print(f"  Reports:           {report_dir}")
    if summary.interrupted:
        return 130
    return 1 if summary.failed else 0


if __name__ == "__main__":
    raise SystemExit(main())
