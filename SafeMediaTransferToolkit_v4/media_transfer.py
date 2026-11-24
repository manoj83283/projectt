#!/usr/bin/env python3
"""Safe, repeatable, content-deduplicating verified media mover.

Moves files from Source A into FORMAT/YEAR/NAMING_GROUP folders. Exact content
duplicates and corrupt files are routed below a user-selected exception root.
A source file is deleted only after its destination is flushed and SHA-256
verified; any failed or interrupted operation leaves the source in place.
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
import time
import unicodedata
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
    from PIL import Image, ImageOps, UnidentifiedImageError
except ImportError:
    Image = None
    ImageOps = None
    class UnidentifiedImageError(Exception):
        pass
try:
    import numpy as np
except ImportError:
    np = None
try:
    from mutagen import File as MutagenFile
except ImportError:
    MutagenFile = None
try:
    from pypdf import PdfReader
except ImportError:
    PdfReader = None

APP_VERSION = "4.0.0"
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
    naming_group: str = "OTHER"
    image_width: int = 0
    image_height: int = 0
    phash: str = ""
    dhash: str = ""
    whash: str = ""
    duplicate_type: str = ""
    matched_canonical_path: str = ""
    phash_distance: Optional[int] = None
    dhash_distance: Optional[int] = None
    whash_distance: Optional[int] = None
    embedding_score: Optional[float] = None
    selected_action: str = ""
    valid: bool = False
    validation: str = "not inspected"
    route: str = ""
    planned_destination: str = ""
    status: str = "PLANNED"
    source_deleted: bool = False
    moved_bytes: int = 0
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
    moved_successful: int = 0
    moved_duplicates: int = 0
    moved_corrupted: int = 0
    successful_bytes: int = 0
    duplicate_bytes: int = 0
    corrupted_bytes: int = 0
    destination_already_present: int = 0
    source_files_deleted: int = 0
    source_files_retained: int = 0
    skipped: int = 0
    failed: int = 0
    bytes_moved: int = 0
    elapsed_seconds: float = 0.0
    zip_archives_found: int = 0
    zip_archives_deleted: int = 0
    zip_archives_retained: int = 0
    zip_members_found: int = 0
    zip_members_finalized: int = 0
    exact_sha256_duplicates: int = 0
    phash_near_duplicates: int = 0
    dhash_near_duplicates: int = 0
    whash_near_duplicates: int = 0
    embedding_reviews: int = 0
    review_needed: int = 0
    review_bytes: int = 0
    interrupted: bool = False
    dry_run: bool = False
    capacity: list[dict] = field(default_factory=list)


class ProgressTracker:
    """Thread-safe console progress plus independent heartbeat logging."""

    def __init__(self, heartbeat_minutes: int):
        self.started = time.monotonic()
        self.stage = "STARTING"
        self.current = ""
        self.files_discovered = 0
        self.files_processed = 0
        self.bytes_read = 0
        self.bytes_moved = 0
        self.total_files = 0
        self.total_work_bytes = 0
        self._last_console = 0.0
        self._last_log = 0.0
        self._heartbeat_seconds = heartbeat_minutes * 60
        self._next_heartbeat = self._heartbeat_seconds
        self._stop = threading.Event()
        self._lock = threading.Lock()
        self._thread = threading.Thread(target=self._heartbeat_worker, name="progress-heartbeat", daemon=True)
        self._thread.start()

    def _snapshot(self) -> str:
        elapsed = max(0.001, time.monotonic() - self.started)
        rate = self.bytes_read / elapsed
        eta = "n/a"
        if self.total_work_bytes > 0 and 0 < self.bytes_read < self.total_work_bytes and rate > 0:
            eta = format_duration((self.total_work_bytes - self.bytes_read) / rate)
        total_files = str(self.total_files) if self.total_files else "?"
        return (
            f"stage={self.stage} | current={self.current or '-'} | "
            f"discovered={self.files_discovered} | processed={self.files_processed}/{total_files} | "
            f"read={format_bytes(self.bytes_read)} | moved={format_bytes(self.bytes_moved)} | "
            f"rate={format_bytes(int(rate))}/s | elapsed={format_duration(elapsed)} | ETA={eta}"
        )

    def emit(self, force: bool = False, log_event: bool = False) -> None:
        now = time.monotonic()
        with self._lock:
            if force or now - self._last_console >= 1.0:
                text = self._snapshot()
                print("\r" + text[:240].ljust(240), end="", flush=True)
                self._last_console = now
            if log_event or now - self._last_log >= 60.0:
                logging.info("PROGRESS %s", self._snapshot())
                self._last_log = now

    def set_stage(self, stage: str, current: str = "") -> None:
        with self._lock:
            self.stage = stage
            self.current = current
        self.emit(force=True, log_event=True)

    def discovered(self, count: int = 1) -> None:
        with self._lock:
            self.files_discovered += count
        self.emit()

    def read(self, count: int, current: Optional[str] = None) -> None:
        with self._lock:
            self.bytes_read += count
            if current:
                self.current = current
        self.emit()

    def moved(self, count: int) -> None:
        with self._lock:
            self.bytes_moved += count
            self.files_processed += 1
        self.emit(force=True, log_event=True)

    def failed(self) -> None:
        with self._lock:
            self.files_processed += 1
        self.emit(force=True, log_event=True)

    def configure_totals(self, total_files: int, total_work_bytes: int) -> None:
        with self._lock:
            self.total_files = total_files
            self.total_work_bytes = total_work_bytes
        self.emit(force=True, log_event=True)

    def _heartbeat_worker(self) -> None:
        while not self._stop.wait(5):
            elapsed = time.monotonic() - self.started
            # Emit on configured cadence independent of read-loop activity.
            if elapsed >= self._next_heartbeat:
                logging.info("HEARTBEAT alive %s", self._snapshot())
                print("\nHEARTBEAT: " + self._snapshot(), flush=True)
                self._next_heartbeat += self._heartbeat_seconds

    def close(self) -> None:
        self._stop.set()
        self._thread.join(timeout=2)
        self.emit(force=True, log_event=True)
        print()


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


def safe_group_name(value: str) -> str:
    value = unicodedata.normalize("NFKC", value).upper()
    value = re.sub(r"[^A-Z0-9]+", "_", value).strip("_")
    if not value:
        return "OTHER"
    if value in WINDOWS_RESERVED:
        value = f"GROUP_{value}"
    return value[:40]


def naming_group(path: Path, fmt: str) -> str:
    """Classify a filename into a stable naming-convention folder."""
    stem = unicodedata.normalize("NFKC", path.stem).strip()
    upper = stem.upper()

    # Requested image-specific conventions. Separators and case are ignored.
    if fmt in {"JPG", "JPEG", "PNG"}:
        if upper.startswith("IMG"):
            return "IMG"
        compact = re.sub(r"[\s_.-]+", "", upper)
        if compact.startswith("SCREENSHOT"):
            return "SCREENSHOTS"

    # Common camera/media conventions get stable, useful groups.
    known = (
        (r"^DSCF?(?:[\s_.-]|\d|$)", "DSC"),
        (r"^DSCN(?:[\s_.-]|\d|$)", "DSCN"),
        (r"^PXL(?:[\s_.-]|\d|$)", "PXL"),
        (r"^VID(?:[\s_.-]|\d|$)", "VID"),
        (r"^MVIMG(?:[\s_.-]|\d|$)", "MVIMG"),
        (r"^WHATSAPP(?:[\s_.-]|\d|$)", "WHATSAPP"),
    )
    for pattern, group in known:
        if re.match(pattern, upper):
            return group

    if re.match(r"^\d", upper):
        return "NUMERIC"

    # Alphabetic prefixes end at a separator, digit, or case-insensitive token
    # boundary. This produces groups such as REPORT, HOLIDAY, SCAN, and GOPR.
    match = re.match(r"^([A-Za-z]+)", stem)
    if match:
        return safe_group_name(match.group(1))
    if upper:
        return "SYMBOL_OR_OTHER"
    return "UNNAMED"


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


def hash_file(path: Path, progress: Optional[ProgressTracker] = None, current: str = "") -> str:
    digest = hashlib.sha256()
    with path.open("rb", buffering=0) as handle:
        while True:
            if _stop_requested.is_set():
                raise InterruptedError("Interrupted while hashing")
            block = handle.read(CHUNK_SIZE)
            if not block:
                break
            digest.update(block)
            if progress:
                progress.read(len(block), current or path.name)
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


def detect_format(path: Path, logical_path: Optional[Path] = None) -> tuple[str, str, str, bool]:
    extension = (logical_path or path).suffix.lower().lstrip(".")
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


def infer_year(path: Path, fmt: str, logical_path: Optional[Path] = None, fallback_year: Optional[int] = None) -> tuple[str, str]:
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

    name_path = logical_path or path
    match = DATE_RE.search(name_path.name) or YEAR_RE.search(name_path.stem)
    if match:
        return match.group(1), "filename"
    for parent in name_path.parents:
        match = YEAR_RE.search(parent.name)
        if match:
            return match.group(1), "parent folder"
    if fallback_year and 1900 <= fallback_year <= 2100:
        return str(fallback_year), "ZIP member timestamp"
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


def inspect_source(
    path: Path,
    deep_media_check: bool,
    progress: Optional[ProgressTracker] = None,
    logical_path: Optional[Path] = None,
    fallback_year: Optional[int] = None,
    precomputed_hash: str = "",
) -> Inspection:
    display_path = logical_path or path
    item = Inspection(source=str(display_path))
    try:
        item.size = path.stat().st_size
        item.format, item.extension, item.signature_extension, item.signature_mismatch = detect_format(path, logical_path)
        item.year, item.year_source = infer_year(path, item.format, logical_path, fallback_year)
        item.naming_group = naming_group(display_path, item.format)
        item.valid, item.validation = validate_file(path, item.format, deep_media_check)
        item.sha256 = precomputed_hash or hash_file(path, progress, str(display_path))
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


@dataclass
class ImageFeatures:
    width: int
    height: int
    phash: str
    dhash: str
    whash: str
    embedding: Optional[object] = None


@dataclass
class CanonicalImage:
    path: str
    sha256: str
    width: int
    height: int
    phash: str
    dhash: str
    whash: str
    embedding: Optional[object] = None
    pending: bool = False


def bits_to_hex(bits) -> str:
    flat = np.asarray(bits, dtype=np.uint8).reshape(-1)
    value = 0
    for bit in flat:
        value = (value << 1) | int(bit)
    return f"{value:0{(len(flat) + 3) // 4}x}"


def hex_hamming(left: str, right: str) -> int:
    if not left or not right or len(left) != len(right):
        return 10_000
    return (int(left, 16) ^ int(right, 16)).bit_count()


def dct_matrix(size: int):
    x = np.arange(size, dtype=np.float32)
    k = x.reshape(-1, 1)
    matrix = np.cos((np.pi / size) * (x + 0.5) * k)
    matrix[0, :] *= np.sqrt(1.0 / size)
    matrix[1:, :] *= np.sqrt(2.0 / size)
    return matrix


_DCT32 = None


def compute_image_features(path: Path, embedding_engine=None) -> ImageFeatures:
    if Image is None or np is None:
        raise RuntimeError("Pillow and NumPy are required for perceptual image matching")
    with Image.open(path) as opened:
        image = ImageOps.exif_transpose(opened).convert("RGB")
        width, height = image.size
        gray32 = np.asarray(image.convert("L").resize((32, 32), Image.Resampling.LANCZOS), dtype=np.float32)
        gray_d = np.asarray(image.convert("L").resize((9, 8), Image.Resampling.LANCZOS), dtype=np.float32)

        dhash = bits_to_hex(gray_d[:, 1:] > gray_d[:, :-1])

        global _DCT32
        if _DCT32 is None:
            _DCT32 = dct_matrix(32)
        transformed = _DCT32 @ gray32 @ _DCT32.T
        low = transformed[:8, :8]
        phash = bits_to_hex(low > np.median(low[1:, :]))

        wave = gray32.copy()
        current = 32
        while current > 8:
            region = wave[:current, :current]
            row_avg = (region[:, 0::2] + region[:, 1::2]) / 2.0
            col_avg = (row_avg[0::2, :] + row_avg[1::2, :]) / 2.0
            current //= 2
            wave[:current, :current] = col_avg
        low_wave = wave[:8, :8]
        whash = bits_to_hex(low_wave > np.median(low_wave[1:, :]))

        embedding = embedding_engine.embed_pil(image) if embedding_engine else None
    return ImageFeatures(width, height, phash, dhash, whash, embedding)


class LocalEmbeddingEngine:
    """Optional CPU-local MobileNetV3-Small embedding extractor."""

    def __init__(self, enabled: bool):
        self.enabled = enabled
        self.model = None
        self.preprocess = None
        self.torch = None
        if not enabled:
            return
        try:
            import torch
            from torchvision.models import MobileNet_V3_Small_Weights, mobilenet_v3_small
        except Exception as exc:
            raise RuntimeError(
                "Embedding mode requires requirements-embeddings.txt (torch and torchvision). "
                f"Import failed: {exc}"
            ) from exc
        self.torch = torch
        weights = MobileNet_V3_Small_Weights.DEFAULT
        self.preprocess = weights.transforms()
        self.model = mobilenet_v3_small(weights=weights)
        self.model.classifier = torch.nn.Identity()
        self.model.eval().to("cpu")

    def embed_pil(self, image):
        if not self.enabled:
            return None
        tensor = self.preprocess(image).unsqueeze(0)
        with self.torch.inference_mode():
            vector = self.model(tensor).squeeze(0).cpu().numpy().astype("float32")
        norm = float(np.linalg.norm(vector))
        if norm:
            vector /= norm
        return vector


class ImageSimilarityIndex:
    def __init__(self, database_path: Path, run_id: str, embedding_engine: LocalEmbeddingEngine):
        self.database_path = database_path
        self.run_id = run_id
        self.embedding_engine = embedding_engine
        self.database_path.parent.mkdir(parents=True, exist_ok=True)
        self.conn = sqlite3.connect(database_path)
        self.conn.execute("PRAGMA journal_mode=WAL")
        self.conn.execute("PRAGMA synchronous=FULL")
        self.conn.execute(
            """
            CREATE TABLE IF NOT EXISTS image_index (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                source_path TEXT,
                final_path TEXT UNIQUE NOT NULL,
                size INTEGER NOT NULL,
                modification_time REAL NOT NULL,
                sha256 TEXT NOT NULL,
                width INTEGER,
                height INTEGER,
                phash TEXT,
                dhash TEXT,
                whash TEXT,
                embedding BLOB,
                embedding_dim INTEGER,
                embedding_index_id INTEGER,
                canonical_path TEXT,
                duplicate_reason TEXT,
                phash_distance INTEGER,
                dhash_distance INTEGER,
                whash_distance INTEGER,
                embedding_score REAL,
                selected_action TEXT,
                run_id TEXT,
                updated_at TEXT
            )
            """
        )
        self.conn.execute("CREATE INDEX IF NOT EXISTS ix_image_sha ON image_index(sha256)")
        self.conn.execute("CREATE INDEX IF NOT EXISTS ix_image_canonical ON image_index(canonical_path)")
        self.conn.commit()
        self.canonicals: list[CanonicalImage] = []

    def _decode_embedding(self, blob, dim):
        if blob is None or not dim or np is None:
            return None
        vector = np.frombuffer(blob, dtype=np.float32, count=dim).copy()
        norm = float(np.linalg.norm(vector))
        return vector / norm if norm else vector

    def load_existing_canonicals(self) -> None:
        self.canonicals.clear()
        rows = self.conn.execute(
            "SELECT final_path,sha256,width,height,phash,dhash,whash,embedding,embedding_dim "
            "FROM image_index WHERE selected_action='CANONICAL'"
        ).fetchall()
        for row in rows:
            if not Path(row[0]).is_file():
                continue
            self.canonicals.append(CanonicalImage(
                path=row[0], sha256=row[1], width=row[2] or 0, height=row[3] or 0,
                phash=row[4] or "", dhash=row[5] or "", whash=row[6] or "",
                embedding=self._decode_embedding(row[7], row[8]), pending=False,
            ))

    def cached_features(self, path: Path) -> Optional[tuple[str, ImageFeatures]]:
        try:
            stat = path.stat()
        except OSError:
            return None
        row = self.conn.execute(
            "SELECT sha256,width,height,phash,dhash,whash,embedding,embedding_dim,size,modification_time "
            "FROM image_index WHERE final_path=? AND selected_action='CANONICAL'",
            (str(path),),
        ).fetchone()
        if not row or row[8] != stat.st_size or abs(row[9] - stat.st_mtime) > 0.0001:
            return None
        if not row[3] or not row[4] or not row[5]:
            return None
        return row[0], ImageFeatures(
            row[1] or 0, row[2] or 0, row[3], row[4], row[5],
            self._decode_embedding(row[6], row[7]),
        )

    def sync_destination(
        self, destination: Path, path_hashes: dict[str, str], progress: ProgressTracker,
    ) -> None:
        progress.set_stage("IMAGE_INDEX_SYNC", str(destination))
        seen_paths: set[str] = set()
        for path in iter_files(destination):
            if is_internal_destination_file(path, destination):
                continue
            fmt, _, _, _ = detect_format(path)
            if fmt not in IMAGE_FORMATS:
                continue
            seen_paths.add(str(path))
            cached = self.cached_features(path)
            try:
                if cached:
                    digest, features = cached
                    if self.embedding_engine.enabled and features.embedding is None:
                        features = compute_image_features(path, self.embedding_engine)
                else:
                    features = compute_image_features(path, self.embedding_engine)
                    digest = path_hashes.get(str(path)) or hash_file(path, progress, str(path))
                self.record_canonical(str(path), str(path), digest, features, "INDEX_SYNC")
            except Exception as exc:
                logging.error("Could not fingerprint destination image %s: %s", path, exc)
        for (indexed_path,) in self.conn.execute(
            "SELECT final_path FROM image_index WHERE selected_action='CANONICAL'"
        ).fetchall():
            if indexed_path not in seen_paths:
                self.conn.execute("DELETE FROM image_index WHERE final_path=?", (indexed_path,))
        self.conn.commit()
        self.load_existing_canonicals()

    def add_pending(self, item: Inspection, final_path: str, embedding) -> None:
        self.canonicals.append(CanonicalImage(
            final_path, item.sha256, item.image_width, item.image_height,
            item.phash, item.dhash, item.whash, embedding, True,
        ))

    def remove_pending(self, path: str) -> None:
        self.canonicals = [c for c in self.canonicals if not (c.pending and c.path == path)]

    def confirm_pending(self, path: str) -> None:
        for canonical in self.canonicals:
            if canonical.path == path:
                canonical.pending = False

    def match(
        self, item: Inspection, embedding, phash_threshold: int,
        dhash_threshold: int, whash_threshold: int, embedding_threshold: float,
    ) -> Optional[dict]:
        if not item.phash:
            return None
        strong: list[tuple] = []
        weak: list[tuple] = []
        embedding_matches: list[tuple] = []
        source_ratio = item.image_width / max(1, item.image_height)
        for canonical in self.canonicals:
            pd = hex_hamming(item.phash, canonical.phash)
            dd = hex_hamming(item.dhash, canonical.dhash)
            wd = hex_hamming(item.whash, canonical.whash)
            target_ratio = canonical.width / max(1, canonical.height)
            ratio_delta = abs(source_ratio - target_ratio) / max(source_ratio, target_ratio, 0.0001)
            p_ok, d_ok, w_ok = pd <= phash_threshold, dd <= dhash_threshold, wd <= whash_threshold
            score = None
            if embedding is not None and canonical.embedding is not None:
                score = float(np.dot(embedding, canonical.embedding))
            row = (canonical, pd, dd, wd, score, ratio_delta)
            # Conservative auto-routing: pHash plus dHash or wHash, with a
            # broadly compatible aspect ratio. Crops/mirrors fall to review.
            if p_ok and (d_ok or w_ok) and ratio_delta <= 0.20:
                strong.append(row)
            elif (p_ok or d_ok or w_ok) and ratio_delta <= 0.35:
                weak.append(row)
            if score is not None and score >= embedding_threshold:
                embedding_matches.append(row)

        def normalized(row):
            _, pd, dd, wd, score, _ = row
            return (pd / max(1, phash_threshold) + dd / max(1, dhash_threshold) + wd / max(1, whash_threshold), -(score or -1))

        if strong:
            canonical, pd, dd, wd, score, _ = min(strong, key=normalized)
            qualifying = [
                (pd / max(1, phash_threshold), "PHASH_NEAR"),
                (dd / max(1, dhash_threshold), "DHASH_NEAR"),
                (wd / max(1, whash_threshold), "WHASH_NEAR"),
            ]
            reason = min(qualifying, key=lambda pair: pair[0])[1]
            return {"kind": "strong", "reason": reason, "canonical": canonical.path,
                    "phash_distance": pd, "dhash_distance": dd, "whash_distance": wd,
                    "embedding_score": score}
        if embedding_matches:
            canonical, pd, dd, wd, score, _ = max(embedding_matches, key=lambda row: row[4])
            return {"kind": "embedding", "reason": "EMBEDDING_REVIEW", "canonical": canonical.path,
                    "phash_distance": pd, "dhash_distance": dd, "whash_distance": wd,
                    "embedding_score": score}
        if weak:
            canonical, pd, dd, wd, score, _ = min(weak, key=normalized)
            reason = "PHASH_NEAR" if pd <= phash_threshold else ("DHASH_NEAR" if dd <= dhash_threshold else "WHASH_NEAR")
            return {"kind": "weak", "reason": reason, "canonical": canonical.path,
                    "phash_distance": pd, "dhash_distance": dd, "whash_distance": wd,
                    "embedding_score": score}
        return None

    def _write_row(
        self, source_path: str, final_path: str, sha256: str, features: ImageFeatures,
        canonical_path: str, duplicate_reason: str, distances: tuple,
        selected_action: str, run_id: str,
    ) -> None:
        path = Path(final_path)
        try:
            stat = path.stat()
            size, mtime = stat.st_size, stat.st_mtime
        except OSError:
            size, mtime = 0, 0.0
        embedding_blob = features.embedding.astype(np.float32).tobytes() if features.embedding is not None else None
        embedding_dim = int(features.embedding.size) if features.embedding is not None else None
        cursor = self.conn.execute(
            """
            INSERT INTO image_index(
                source_path,final_path,size,modification_time,sha256,width,height,
                phash,dhash,whash,embedding,embedding_dim,canonical_path,
                duplicate_reason,phash_distance,dhash_distance,whash_distance,
                embedding_score,selected_action,run_id,updated_at
            ) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
            ON CONFLICT(final_path) DO UPDATE SET
                source_path=excluded.source_path,size=excluded.size,modification_time=excluded.modification_time,
                sha256=excluded.sha256,width=excluded.width,height=excluded.height,
                phash=excluded.phash,dhash=excluded.dhash,whash=excluded.whash,
                embedding=excluded.embedding,embedding_dim=excluded.embedding_dim,
                canonical_path=excluded.canonical_path,duplicate_reason=excluded.duplicate_reason,
                phash_distance=excluded.phash_distance,dhash_distance=excluded.dhash_distance,
                whash_distance=excluded.whash_distance,embedding_score=excluded.embedding_score,
                selected_action=excluded.selected_action,run_id=excluded.run_id,updated_at=excluded.updated_at
            """,
            (source_path, final_path, size, mtime, sha256, features.width, features.height,
             features.phash, features.dhash, features.whash, embedding_blob, embedding_dim,
             canonical_path, duplicate_reason, distances[0], distances[1], distances[2],
             distances[3], selected_action, run_id, iso_now()),
        )
        row_id = self.conn.execute("SELECT id FROM image_index WHERE final_path=?", (final_path,)).fetchone()[0]
        self.conn.execute("UPDATE image_index SET embedding_index_id=? WHERE id=?", (row_id, row_id))
        self.conn.commit()

    def record_canonical(self, source_path: str, final_path: str, sha256: str, features: ImageFeatures, run_id: str) -> None:
        self._write_row(source_path, final_path, sha256, features, final_path, "", (None, None, None, None), "CANONICAL", run_id)

    def record_item(self, item: Inspection, final_path: str, embedding) -> None:
        features = ImageFeatures(item.image_width, item.image_height, item.phash, item.dhash, item.whash, embedding)
        action = "CANONICAL" if item.route == "unique" else item.selected_action
        canonical = final_path if item.route == "unique" else item.matched_canonical_path
        self._write_row(
            item.source, final_path, item.sha256, features, canonical, item.duplicate_type,
            (item.phash_distance, item.dhash_distance, item.whash_distance, item.embedding_score),
            action, self.run_id,
        )

    def close(self) -> None:
        self.conn.commit()
        self.conn.close()


def attach_image_features(item: Inspection, path: Path, engine: LocalEmbeddingEngine):
    if item.format not in IMAGE_FORMATS or not item.valid:
        return None
    features = compute_image_features(path, engine if engine.enabled else None)
    item.image_width = features.width
    item.image_height = features.height
    item.phash = features.phash
    item.dhash = features.dhash
    item.whash = features.whash
    return features.embedding

@dataclass
class ZipPlan:
    path: Path
    members: list[zipfile.ZipInfo] = field(default_factory=list)
    scan_error: str = ""


def format_bytes(value: int) -> str:
    units = ["B", "KiB", "MiB", "GiB", "TiB"]
    amount = float(max(0, value))
    for unit in units:
        if amount < 1024 or unit == units[-1]:
            return f"{amount:.2f} {unit}"
        amount /= 1024
    return f"{value} B"


def format_duration(seconds: float) -> str:
    seconds = max(0, int(seconds))
    hours, remainder = divmod(seconds, 3600)
    minutes, secs = divmod(remainder, 60)
    if hours:
        return f"{hours:02d}:{minutes:02d}:{secs:02d}"
    return f"{minutes:02d}:{secs:02d}"


def is_internal_destination_file(path: Path, destination: Path) -> bool:
    try:
        rel = path.relative_to(destination)
    except ValueError:
        return False
    return bool(rel.parts and rel.parts[0] == ".media_transfer") or bool(OWN_TEMP_FILE.match(path.name))


def cleanup_stale_temp_files(roots: Iterable[Path]) -> int:
    """Remove only UUID-named temp files created by this toolkit."""
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
                logging.warning("Removed stale interrupted-operation temp file: %s", path)
            except OSError as exc:
                logging.warning("Could not remove stale temp file %s: %s", path, exc)
    return removed


def index_destination(destination: Path, progress: ProgressTracker) -> tuple[dict[str, list[str]], int, int]:
    index: dict[str, list[str]] = {}
    count = errors = 0
    if not destination.exists():
        return index, count, errors
    progress.set_stage("DESTINATION_INDEX", str(destination))
    for path in iter_files(destination):
        if is_internal_destination_file(path, destination):
            continue
        try:
            digest = hash_file(path, progress, str(path))
            index.setdefault(digest, []).append(str(path))
            count += 1
        except InterruptedError:
            raise
        except Exception as exc:
            errors += 1
            logging.error("Could not hash destination file %s: %s", path, exc)
    return index, count, errors


def logical_source_name(item: Inspection) -> str:
    raw = item.source.split("::", 1)[-1]
    return Path(raw.replace("\\", "/")).name


def choose_target(root: Path, item: Inspection, reserved: set[Path]) -> Path:
    directory = root / item.format / item.year / item.naming_group
    filename = safe_filename(logical_source_name(item))
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


def capacity_plan(
    items: list[Inspection], roots: dict[str, Path], reserve_bytes: int,
    zip_total_bytes: int, zip_max_member: int, staging_root: Path,
) -> list[dict]:
    grouped: dict[tuple, dict] = {}
    for root in set(roots.values()):
        key = volume_key(root)
        grouped.setdefault(key, {"paths": set(), "required_bytes": 0})["paths"].add(str(root))
    for item in items:
        if item.route not in roots:
            continue
        root = roots[item.route]
        record = grouped[volume_key(root)]
        required = max(0, item.size)
        target = Path(item.planned_destination)
        if target.exists() and item.sha256:
            try:
                if hash_file(target) == item.sha256:
                    required = 0
            except Exception:
                pass
        record["required_bytes"] += required

    # ZIP routes are unknown until each member is streamed and validated. The
    # safe preflight reserves all declared ZIP bytes on every possible target
    # volume. On the staging volume it also reserves the largest member temp.
    for record in grouped.values():
        record["required_bytes"] += zip_total_bytes
    staging_key = volume_key(staging_root)
    grouped.setdefault(staging_key, {"paths": {str(staging_root)}, "required_bytes": zip_total_bytes})
    grouped[staging_key]["required_bytes"] += zip_max_member

    reports = []
    for data in grouped.values():
        probe = nearest_existing(Path(next(iter(data["paths"]))))
        usage = shutil.disk_usage(probe)
        required = data["required_bytes"]
        margin = max(reserve_bytes, int(required * 0.05))
        reports.append({
            "paths": sorted(data["paths"]), "required_bytes": required,
            "safety_margin_bytes": margin, "free_bytes": usage.free,
            "sufficient": usage.free >= required + margin,
            "zip_unknown_route_reservation": zip_total_bytes,
        })
    return reports


def ensure_free_space(target_dir: Path, needed: int, reserve_bytes: int) -> None:
    probe = nearest_existing(target_dir)
    free = shutil.disk_usage(probe).free
    if free < needed + reserve_bytes:
        raise OSError(
            f"Insufficient free space at {probe}: need {format_bytes(needed + reserve_bytes)}, "
            f"available {format_bytes(free)}"
        )


def fsync_directory(path: Path) -> None:
    if os.name == "nt":
        return
    try:
        descriptor = os.open(path, os.O_RDONLY)
        try:
            os.fsync(descriptor)
        finally:
            os.close(descriptor)
    except OSError:
        pass


def verified_move_ordinary(
    source: Path, target: Path, expected_hash: str, reserve_bytes: int,
    progress: ProgressTracker, delete_source: bool = True,
) -> tuple[str, int]:
    """Finalize target first; unlink source only after final SHA-256 verification."""
    if not expected_hash:
        raise IOError("Source could not be fully hashed; source retained")
    target.parent.mkdir(parents=True, exist_ok=True)
    size = source.stat().st_size
    if target.exists():
        source_hash = hash_file(source, progress, str(source))
        target_hash = hash_file(target, progress, str(target))
        if source_hash != expected_hash or target_hash != expected_hash:
            raise FileExistsError(f"Refusing to overwrite different file: {target}")
        if delete_source:
            if _stop_requested.is_set():
                raise InterruptedError("Interrupted before source deletion")
            source.unlink()
            return "MOVED_TO_VERIFIED_EXISTING", size
        return "COPIED_TO_REVIEW_VERIFIED_EXISTING_SOURCE_RETAINED", size

    ensure_free_space(target.parent, size, reserve_bytes)
    temp_path = target.parent / f".{target.name}.{uuid.uuid4().hex}.part"
    written = 0
    stream_hash = hashlib.sha256()
    try:
        with source.open("rb", buffering=0) as src, temp_path.open("xb", buffering=0) as dst:
            while True:
                if _stop_requested.is_set():
                    raise InterruptedError("Interrupted during ordinary-file move")
                block = src.read(CHUNK_SIZE)
                if not block:
                    break
                dst.write(block)
                stream_hash.update(block)
                written += len(block)
                progress.read(len(block), str(source))
            dst.flush()
            os.fsync(dst.fileno())
        if stream_hash.hexdigest() != expected_hash:
            raise IOError("Source changed after inspection or streaming SHA-256 mismatch")
        if hash_file(temp_path, progress, str(temp_path)) != expected_hash:
            raise IOError("Temporary destination SHA-256 verification failed")
        try:
            shutil.copystat(source, temp_path, follow_symlinks=False)
        except OSError as exc:
            logging.warning("Could not preserve all metadata for %s: %s", source, exc)
        os.replace(temp_path, target)
        fsync_directory(target.parent)
        if hash_file(target, progress, str(target)) != expected_hash:
            raise IOError("Final destination SHA-256 verification failed; source retained")
        if delete_source:
            if _stop_requested.is_set():
                raise InterruptedError("Interrupted after finalization; source retained")
            source.unlink()
            return "MOVED_VERIFIED", written
        return "COPIED_TO_REVIEW_VERIFIED_SOURCE_RETAINED", written
    except BaseException:
        try:
            temp_path.unlink(missing_ok=True)
        except OSError:
            pass
        raise


def stream_zip_member_to_temp(
    archive: zipfile.ZipFile, member: zipfile.ZipInfo, staging_root: Path,
    reserve_bytes: int, progress: ProgressTracker,
) -> tuple[Path, str, int]:
    staging_root.mkdir(parents=True, exist_ok=True)
    ensure_free_space(staging_root, max(0, member.file_size), reserve_bytes)
    temp_path = staging_root / f".zipmember.{uuid.uuid4().hex}.part"
    digest = hashlib.sha256()
    written = 0
    label = f"{Path(archive.filename).name}::{member.filename}"
    progress.set_stage("ZIP_MEMBER_STREAM", label)
    try:
        with archive.open(member, "r") as src, temp_path.open("xb", buffering=0) as dst:
            while True:
                if _stop_requested.is_set():
                    raise InterruptedError("Interrupted while streaming ZIP member")
                block = src.read(CHUNK_SIZE)
                if not block:
                    break
                dst.write(block)
                digest.update(block)
                written += len(block)
                progress.read(len(block), label)
            dst.flush()
            os.fsync(dst.fileno())
        if written != member.file_size:
            raise IOError(f"ZIP member size mismatch: expected {member.file_size}, got {written}")
        return temp_path, digest.hexdigest(), written
    except BaseException:
        try:
            temp_path.unlink(missing_ok=True)
        except OSError:
            pass
        raise


def finalize_staged_member(
    staged: Path, target: Path, expected_hash: str, reserve_bytes: int,
    progress: ProgressTracker,
) -> tuple[str, int]:
    target.parent.mkdir(parents=True, exist_ok=True)
    size = staged.stat().st_size
    if hash_file(staged, progress, str(staged)) != expected_hash:
        raise IOError("Staged ZIP member SHA-256 verification failed")
    if target.exists():
        if hash_file(target, progress, str(target)) != expected_hash:
            raise FileExistsError(f"Refusing to overwrite different file: {target}")
        staged.unlink()
        return "FINALIZED_TO_VERIFIED_EXISTING", size

    ensure_free_space(target.parent, size, reserve_bytes)
    target_temp = target.parent / f".{target.name}.{uuid.uuid4().hex}.part"
    try:
        # os.replace is atomic only on the same filesystem. Otherwise create a
        # second target-local .part, flush and verify it before finalization.
        if volume_key(staged) == volume_key(target.parent):
            os.replace(staged, target_temp)
        else:
            digest = hashlib.sha256()
            with staged.open("rb", buffering=0) as src, target_temp.open("xb", buffering=0) as dst:
                while True:
                    if _stop_requested.is_set():
                        raise InterruptedError("Interrupted moving staged ZIP member")
                    block = src.read(CHUNK_SIZE)
                    if not block:
                        break
                    dst.write(block)
                    digest.update(block)
                    progress.read(len(block), str(target))
                dst.flush()
                os.fsync(dst.fileno())
            if digest.hexdigest() != expected_hash:
                raise IOError("Cross-filesystem ZIP member copy hash mismatch")
        if hash_file(target_temp, progress, str(target_temp)) != expected_hash:
            raise IOError("Target-local ZIP member .part verification failed")
        os.replace(target_temp, target)
        fsync_directory(target.parent)
        if hash_file(target, progress, str(target)) != expected_hash:
            raise IOError("Final ZIP member SHA-256 verification failed")
        staged.unlink(missing_ok=True)
        return "ZIP_MEMBER_FINALIZED_VERIFIED", size
    except BaseException:
        try:
            target_temp.unlink(missing_ok=True)
        except OSError:
            pass
        try:
            staged.unlink(missing_ok=True)
        except OSError:
            pass
        raise


def scan_source(source: Path, progress: ProgressTracker) -> tuple[list[Path], list[ZipPlan]]:
    ordinary: list[Path] = []
    archives: list[ZipPlan] = []
    progress.set_stage("DIRECTORY_SCAN", str(source))
    for current, dirs, files in os.walk(source, followlinks=False):
        dirs[:] = sorted(d for d in dirs if not (Path(current) / d).is_symlink())
        progress.set_stage("DIRECTORY_SCAN", str(current))
        for name in sorted(files):
            path = Path(current) / name
            if path.is_symlink() or not path.is_file():
                logging.warning("Skipping non-ordinary source entry: %s", path)
                continue
            progress.discovered()
            if path.suffix.lower() == ".zip":
                plan = ZipPlan(path=path)
                progress.set_stage("ZIP_ARCHIVE_SCAN", str(path))
                try:
                    with zipfile.ZipFile(path, "r") as archive:
                        for member in archive.infolist():
                            if member.is_dir():
                                continue
                            plan.members.append(member)
                            progress.discovered()
                except Exception as exc:
                    plan.scan_error = f"{type(exc).__name__}: {exc}"
                archives.append(plan)
            else:
                ordinary.append(path)
    return ordinary, archives


def classify_item(
    item: Inspection, destination_index: dict[str, list[str]], seen: dict[str, str],
    summary: Summary, image_index: ImageSimilarityIndex, embedding,
    phash_threshold: int, dhash_threshold: int, whash_threshold: int,
    embedding_threshold: float, review_only_near: bool,
) -> None:
    if not item.sha256:
        item.route = "corrupt"
        item.selected_action = "CORRUPTED_UNREADABLE"
        summary.planned_corrupt += 1
    elif not item.valid:
        item.route = "corrupt"
        item.selected_action = "CORRUPTED_FORMAT_VALIDATION"
        summary.planned_corrupt += 1
    elif item.sha256 in destination_index or item.sha256 in seen:
        item.route = "duplicate"
        item.duplicate_type = "EXACT_SHA256"
        item.matched_canonical_path = (
            destination_index.get(item.sha256, [""])[0] if item.sha256 in destination_index
            else seen[item.sha256]
        )
        if item.phash:
            item.phash_distance = 0
            item.dhash_distance = 0
            item.whash_distance = 0
            item.embedding_score = 1.0 if embedding is not None else None
        item.selected_action = "ROUTE_DUPLICATE_EXACT"
        summary.planned_duplicates += 1
    else:
        match = image_index.match(
            item, embedding, phash_threshold, dhash_threshold,
            whash_threshold, embedding_threshold,
        ) if item.phash else None
        if match:
            item.duplicate_type = match["reason"]
            item.matched_canonical_path = match["canonical"]
            item.phash_distance = match["phash_distance"]
            item.dhash_distance = match["dhash_distance"]
            item.whash_distance = match["whash_distance"]
            item.embedding_score = match["embedding_score"]
            if match["kind"] == "strong" and not review_only_near:
                item.route = "duplicate"
                item.selected_action = "ROUTE_DUPLICATE_STRONG_PERCEPTUAL"
                summary.planned_duplicates += 1
            else:
                item.route = "review"
                item.selected_action = (
                    "REVIEW_NEEDED_EMBEDDING" if match["kind"] == "embedding"
                    else "REVIEW_NEEDED_NEAR_IMAGE"
                )
        else:
            item.route = "unique"
            item.selected_action = "KEEP_CANONICAL"
            summary.planned_unique += 1


def count_success(summary: Summary, item: Inspection, moved_bytes: int, existing: bool = False) -> None:
    item.moved_bytes = moved_bytes
    if existing:
        summary.destination_already_present += 1
    if item.route == "unique":
        summary.moved_successful += 1
        summary.successful_bytes += moved_bytes
    elif item.route == "duplicate":
        summary.moved_duplicates += 1
        summary.duplicate_bytes += moved_bytes
        if item.duplicate_type == "EXACT_SHA256":
            summary.exact_sha256_duplicates += 1
        elif item.duplicate_type == "PHASH_NEAR":
            summary.phash_near_duplicates += 1
        elif item.duplicate_type == "DHASH_NEAR":
            summary.dhash_near_duplicates += 1
        elif item.duplicate_type == "WHASH_NEAR":
            summary.whash_near_duplicates += 1
    elif item.route == "corrupt":
        summary.moved_corrupted += 1
        summary.corrupted_bytes += moved_bytes
    summary.bytes_moved += moved_bytes


def count_review(summary: Summary, item: Inspection, copied_bytes: int) -> None:
    item.moved_bytes = copied_bytes
    summary.review_needed += 1
    summary.review_bytes += copied_bytes
    if item.duplicate_type == "EMBEDDING_REVIEW":
        summary.embedding_reviews += 1
    elif item.duplicate_type == "PHASH_NEAR":
        summary.phash_near_duplicates += 1
    elif item.duplicate_type == "DHASH_NEAR":
        summary.dhash_near_duplicates += 1
    elif item.duplicate_type == "WHASH_NEAR":
        summary.whash_near_duplicates += 1


def setup_logging(report_dir: Path, verbose: bool) -> None:
    report_dir.mkdir(parents=True, exist_ok=True)
    handlers = [logging.FileHandler(report_dir / "transfer.log", encoding="utf-8"), logging.StreamHandler()]
    logging.basicConfig(
        level=logging.DEBUG if verbose else logging.INFO,
        format="%(asctime)s %(levelname)s %(message)s",
        handlers=handlers, force=True,
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
    report = [
        "SAFE MEDIA TRANSFER - FINAL REPORT",
        "=" * 40,
        f"Run ID: {summary.run_id}",
        f"Started: {summary.started_at}",
        f"Finished: {summary.finished_at}",
        f"Elapsed time: {format_duration(summary.elapsed_seconds)} ({summary.elapsed_seconds:.2f} seconds)",
        "",
        f"Files discovered: {summary.source_files}",
        f"Source bytes represented: {summary.source_bytes} ({format_bytes(summary.source_bytes)})",
        f"Successful unique: {summary.moved_successful} files, {summary.successful_bytes} bytes ({format_bytes(summary.successful_bytes)})",
        f"Duplicates: {summary.moved_duplicates} files, {summary.duplicate_bytes} bytes ({format_bytes(summary.duplicate_bytes)})",
        "Image duplicate/review classification counts:",
        f"  EXACT_SHA256: {summary.exact_sha256_duplicates}",
        f"  PHASH_NEAR: {summary.phash_near_duplicates}",
        f"  DHASH_NEAR: {summary.dhash_near_duplicates}",
        f"  WHASH_NEAR: {summary.whash_near_duplicates}",
        f"Review needed: {summary.review_needed} files, {summary.review_bytes} bytes ({format_bytes(summary.review_bytes)})",
        f"  EMBEDDING_REVIEW: {summary.embedding_reviews}",
        f"Corrupted: {summary.moved_corrupted} files, {summary.corrupted_bytes} bytes ({format_bytes(summary.corrupted_bytes)})",
        f"Failed: {summary.failed} files/operations",
        f"Total moved/finalized: {summary.moved_successful + summary.moved_duplicates + summary.moved_corrupted} files, {summary.bytes_moved} bytes ({format_bytes(summary.bytes_moved)})",
        f"Total review copies with source retained: {summary.review_needed} files, {summary.review_bytes} bytes ({format_bytes(summary.review_bytes)})",
        f"Source logical files deleted: {summary.source_files_deleted}",
        f"Source logical files retained: {summary.source_files_retained}",
        "",
        f"ZIP archives found: {summary.zip_archives_found}",
        f"ZIP archives deleted after all members succeeded: {summary.zip_archives_deleted}",
        f"ZIP archives retained: {summary.zip_archives_retained}",
        f"ZIP members found: {summary.zip_members_found}",
        f"ZIP members finalized: {summary.zip_members_finalized}",
        f"Interrupted: {summary.interrupted}",
        f"Dry run: {summary.dry_run}",
    ]
    (report_dir / "final_report.txt").write_text("\n".join(report) + "\n", encoding="utf-8")


def prompt_if_missing(args) -> None:
    print("\nSafe Media Transfer - verified move with ZIP streaming\n")
    if not args.source:
        args.source = input("Source A folder: ").strip()
    if not args.destination:
        args.destination = input("Destination B folder (unique files): ").strip()
    if not args.exception_root:
        args.exception_root = input("Root folder for Duplicates, Corrupted, and REVIEW_NEEDED: ").strip()


def parse_args(argv: Optional[list[str]] = None):
    parser = argparse.ArgumentParser(
        description="Verified-move ordinary files and streamed ZIP members into FORMAT/YEAR/NAMING_GROUP folders.",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    parser.add_argument("--source", help="Source A directory")
    parser.add_argument("--destination", help="Destination B directory for unique files")
    parser.add_argument("--exception-root", help="Root under which Duplicates and Corrupted are automatically created")
    parser.add_argument("--metadata-dir", help="Persistent SQLite metadata directory (default: Destination B/.media_transfer/metadata)")
    parser.add_argument("--report-dir", help="Custom report directory (default: Destination B/.media_transfer/reports/<run>)")
    parser.add_argument("--dry-run", action="store_true", help="Scan, inspect ordinary files, and plan without moving or streaming ZIP members")
    parser.add_argument("--allow-partial", action="store_true", help="Override aggregate capacity failure; per-file checks still stop unsafe work")
    parser.add_argument("--deep-media-check", action="store_true", help="Use ffprobe for media validation when installed")
    parser.add_argument("--reserve-mb", type=int, default=100, help="Free-space reserve maintained on each destination volume")
    parser.add_argument("--heartbeat-minutes", type=int, choices=(30, 60), default=30, help="Visible/logged heartbeat interval")
    parser.add_argument("--phash-threshold", type=int, default=4, help="Maximum 64-bit pHash Hamming distance")
    parser.add_argument("--dhash-threshold", type=int, default=3, help="Maximum 64-bit dHash Hamming distance")
    parser.add_argument("--whash-threshold", type=int, default=4, help="Maximum 64-bit wHash Hamming distance")
    parser.add_argument("--embedding-threshold", type=float, default=0.94, help="Minimum cosine score for embedding review")
    parser.add_argument("--enable-embeddings", action="store_true", help="Enable optional local MobileNetV3 image embeddings on CPU")
    parser.add_argument("--review-only-near", action="store_true", help="Copy perceptual/embedding near matches to REVIEW_NEEDED and retain their source")
    parser.add_argument("--verbose", action="store_true", help="Enable verbose logs")
    parser.add_argument("--version", action="version", version=f"%(prog)s {APP_VERSION}")
    return parser.parse_args(argv)


def make_archive_control(path: Path, status: str, error: str) -> Inspection:
    try:
        size = path.stat().st_size
    except OSError:
        size = 0
    item = Inspection(
        source=str(path), size=size, format="ZIP", extension="zip",
        year=str(dt.datetime.fromtimestamp(path.stat().st_mtime).year) if path.exists() else "UNKNOWN",
        year_source="archive modified time", naming_group=naming_group(path, "ZIP"),
        valid=False, validation="archive control record", route="archive",
        status=status, error=error,
    )
    return item


def canonical_is_available(item: Inspection) -> bool:
    if not item.matched_canonical_path:
        return True
    canonical = Path(item.matched_canonical_path)
    if not canonical.is_file():
        return False
    if item.duplicate_type == "EXACT_SHA256":
        try:
            return hash_file(canonical) == item.sha256
        except Exception:
            return False
    return True


def main(argv: Optional[list[str]] = None) -> int:
    args = parse_args(argv)
    prompt_if_missing(args)
    for name in ("phash_threshold", "dhash_threshold", "whash_threshold"):
        if getattr(args, name) < 0 or getattr(args, name) > 64:
            raise ValueError(f"--{name.replace('_', '-')} must be between 0 and 64")
    if not -1.0 <= args.embedding_threshold <= 1.0:
        raise ValueError("--embedding-threshold must be between -1 and 1")

    source = normalized_path(args.source)
    destination = normalized_path(args.destination)
    exception_root = normalized_path(args.exception_root)
    duplicates = exception_root / "Duplicates"
    corrupted = exception_root / "Corrupted"
    review_needed = exception_root / "REVIEW_NEEDED"
    validate_path_layout(source, destination, duplicates, corrupted)
    if review_needed == source or path_is_within(review_needed, source) or path_is_within(source, review_needed):
        raise ValueError(f"REVIEW_NEEDED must not overlap Source A: {review_needed}")
    destination.mkdir(parents=True, exist_ok=True)
    duplicates.mkdir(parents=True, exist_ok=True)
    corrupted.mkdir(parents=True, exist_ok=True)
    review_needed.mkdir(parents=True, exist_ok=True)

    run_id = dt.datetime.now().strftime("%Y%m%d_%H%M%S") + "_" + uuid.uuid4().hex[:8]
    report_dir = normalized_path(args.report_dir) if args.report_dir else destination / ".media_transfer" / "reports" / run_id
    metadata_dir = normalized_path(args.metadata_dir) if args.metadata_dir else destination / ".media_transfer" / "metadata"
    staging_root = destination / ".media_transfer" / "temp"
    setup_logging(report_dir, args.verbose)
    for signum in (getattr(signal, "SIGINT", None), getattr(signal, "SIGTERM", None)):
        if signum is not None:
            signal.signal(signum, request_stop)

    started_mono = time.monotonic()
    summary = Summary(run_id=run_id, started_at=iso_now(), dry_run=args.dry_run)
    progress = ProgressTracker(args.heartbeat_minutes)
    reserve_bytes = max(0, args.reserve_mb) * 1024 * 1024
    config = {
        "source": str(source), "destination": str(destination),
        "exception_root": str(exception_root), "duplicates": str(duplicates),
        "corrupted": str(corrupted), "review_needed": str(review_needed),
        "metadata_dir": str(metadata_dir), "report_dir": str(report_dir),
        "dry_run": args.dry_run, "allow_partial": args.allow_partial,
        "deep_media_check": args.deep_media_check, "reserve_mb": max(0, args.reserve_mb),
        "heartbeat_minutes": args.heartbeat_minutes,
        "phash_threshold": args.phash_threshold, "dhash_threshold": args.dhash_threshold,
        "whash_threshold": args.whash_threshold, "embedding_threshold": args.embedding_threshold,
        "enable_embeddings": args.enable_embeddings, "review_only_near": args.review_only_near,
        "online_uploads": False,
    }
    items: list[Inspection] = []
    fatal_error = ""
    image_index: Optional[ImageSimilarityIndex] = None

    try:
        logging.info("Run %s started; all image analysis is local", run_id)
        embedding_engine = LocalEmbeddingEngine(args.enable_embeddings)
        image_index = ImageSimilarityIndex(metadata_dir / "image_index.sqlite3", run_id, embedding_engine)
        if not args.dry_run:
            cleanup_stale_temp_files((destination, duplicates, corrupted, review_needed))
        ordinary_paths, archive_plans = scan_source(source, progress)
        summary.zip_archives_found = len(archive_plans)
        summary.zip_members_found = sum(len(p.members) for p in archive_plans)
        ordinary_bytes = sum(p.stat().st_size for p in ordinary_paths)
        zip_total_bytes = sum(m.file_size for p in archive_plans for m in p.members)
        zip_max_member = max((m.file_size for p in archive_plans for m in p.members), default=0)
        unreadable_archives = sum(1 for p in archive_plans if p.scan_error or not p.members)
        summary.source_files = len(ordinary_paths) + summary.zip_members_found + unreadable_archives
        summary.source_bytes = ordinary_bytes + zip_total_bytes + sum(
            p.path.stat().st_size for p in archive_plans if (p.scan_error or not p.members) and p.path.exists()
        )
        progress.configure_totals(summary.source_files, ordinary_bytes * 4 + zip_total_bytes * 3)

        destination_index, summary.destination_files_indexed, summary.destination_hash_errors = index_destination(destination, progress)
        if summary.destination_hash_errors:
            raise RuntimeError("Destination B contains unreadable files; duplicate prevention cannot be guaranteed")
        path_hashes = {path: digest for digest, paths in destination_index.items() for path in paths}
        image_index.sync_destination(destination, path_hashes, progress)

        seen: dict[str, str] = {}
        reserved_targets: set[Path] = set()
        roots = {"unique": destination, "duplicate": duplicates, "corrupt": corrupted, "review": review_needed}
        progress.set_stage("ORDINARY_FILE_INSPECTION", str(source))
        ordinary_items: list[Inspection] = []
        ordinary_embeddings: dict[str, object] = {}
        for number, path in enumerate(ordinary_paths, 1):
            if _stop_requested.is_set():
                raise InterruptedError("Interrupted during ordinary-file inspection")
            progress.set_stage("ORDINARY_FILE_HASHING", f"{number}/{len(ordinary_paths)} {path}")
            item = inspect_source(path, args.deep_media_check, progress)
            embedding = None
            if item.valid and item.format in IMAGE_FORMATS:
                try:
                    progress.set_stage("IMAGE_PERCEPTUAL_HASH", str(path))
                    embedding = attach_image_features(item, path, embedding_engine)
                except Exception as exc:
                    logging.error("Image similarity unavailable for %s; exact SHA-256 remains active: %s", path, exc)
                    item.error = f"Image similarity unavailable: {type(exc).__name__}: {exc}"
            classify_item(
                item, destination_index, seen, summary, image_index, embedding,
                args.phash_threshold, args.dhash_threshold, args.whash_threshold,
                args.embedding_threshold, args.review_only_near,
            )
            item.planned_destination = str(choose_target(roots[item.route], item, reserved_targets))
            if item.route == "unique":
                seen[item.sha256] = item.planned_destination
                if item.phash:
                    image_index.add_pending(item, item.planned_destination, embedding)
            if embedding is not None:
                ordinary_embeddings[item.source] = embedding
            ordinary_items.append(item)
            items.append(item)

        summary.capacity = capacity_plan(
            ordinary_items, roots, reserve_bytes, zip_total_bytes, zip_max_member, staging_root
        )
        for entry in summary.capacity:
            logging.info(
                "CAPACITY paths=%s required=%s margin=%s free=%s sufficient=%s",
                ", ".join(entry["paths"]), format_bytes(entry["required_bytes"]),
                format_bytes(entry["safety_margin_bytes"]), format_bytes(entry["free_bytes"]), entry["sufficient"],
            )
        if any(not e["sufficient"] for e in summary.capacity) and not args.allow_partial and not args.dry_run:
            for item in ordinary_items:
                item.status = "NOT_MOVED_CAPACITY_PREFLIGHT"
            raise OSError("Preflight storage-capacity check failed. No source files were deleted")

        if args.dry_run:
            for item in ordinary_items:
                item.status = "DRY_RUN"
            for plan in archive_plans:
                reason = plan.scan_error or ("No eligible regular-file members" if not plan.members else "ZIP members not streamed in dry-run")
                items.append(make_archive_control(plan.path, "DRY_RUN_ZIP_RETAINED", reason))
            logging.info("Dry run complete; no source files were deleted and no ZIP members were extracted")
        else:
            progress.set_stage("ORDINARY_FILE_MOVE", str(source))
            for item in ordinary_items:
                if _stop_requested.is_set():
                    raise InterruptedError("Interrupted before ordinary-file move")
                embedding = ordinary_embeddings.get(item.source)
                try:
                    if item.route in {"duplicate", "review"} and not canonical_is_available(item):
                        logging.warning("Matched canonical unavailable; promoting to canonical: %s", item.source)
                        item.route = "unique"
                        item.selected_action = "PROMOTED_CANONICAL_MISSING"
                        item.duplicate_type = ""
                        item.matched_canonical_path = ""
                        item.planned_destination = str(choose_target(destination, item, reserved_targets))
                        seen[item.sha256] = item.planned_destination
                        if item.phash:
                            image_index.add_pending(item, item.planned_destination, embedding)

                    retain_source = item.route == "review"
                    status, moved_bytes = verified_move_ordinary(
                        Path(item.source), Path(item.planned_destination), item.sha256,
                        reserve_bytes, progress, delete_source=not retain_source,
                    )
                    item.status = status
                    if retain_source:
                        count_review(summary, item, moved_bytes)
                    else:
                        item.source_deleted = True
                        summary.source_files_deleted += 1
                        count_success(summary, item, moved_bytes, "EXISTING" in status)
                    progress.moved(moved_bytes)
                    if item.route == "unique":
                        destination_index.setdefault(item.sha256, []).append(item.planned_destination)
                        image_index.confirm_pending(item.planned_destination)
                    if item.phash:
                        image_index.record_item(item, item.planned_destination, embedding)
                    logging.info("FINALIZED %s -> %s [%s/%s]", item.source, item.planned_destination, item.route, status)
                except InterruptedError:
                    item.status = "INTERRUPTED_SOURCE_RETAINED"
                    if item.route == "unique":
                        image_index.remove_pending(item.planned_destination)
                    raise
                except Exception as exc:
                    item.status = "FAILED_SOURCE_RETAINED"
                    item.error = f"{type(exc).__name__}: {exc}"
                    if item.route == "unique":
                        image_index.remove_pending(item.planned_destination)
                    summary.failed += 1
                    progress.failed()
                    logging.error("Ordinary file retained after failure %s: %s", item.source, exc)
                    if "Insufficient free space" in str(exc):
                        raise OSError(str(exc))

            for archive_number, plan in enumerate(archive_plans, 1):
                if _stop_requested.is_set():
                    raise InterruptedError("Interrupted before ZIP archive")
                progress.set_stage("ZIP_ARCHIVE_PROCESS", f"{archive_number}/{len(archive_plans)} {plan.path}")
                if plan.scan_error or not plan.members:
                    reason = plan.scan_error or "No eligible regular-file members"
                    items.append(make_archive_control(plan.path, "ZIP_RETAINED", reason))
                    summary.zip_archives_retained += 1
                    summary.failed += 1
                    progress.failed()
                    logging.error("ZIP retained %s: %s", plan.path, reason)
                    continue

                archive_ok = True
                archive_member_items: list[Inspection] = []
                failure_reasons: list[str] = []
                try:
                    with zipfile.ZipFile(plan.path, "r") as archive:
                        for member_number, member in enumerate(plan.members, 1):
                            label = f"{archive_number}/{len(archive_plans)} {plan.path.name} member {member_number}/{len(plan.members)} {member.filename}"
                            staged: Optional[Path] = None
                            item: Optional[Inspection] = None
                            embedding = None
                            try:
                                staged, digest, written = stream_zip_member_to_temp(
                                    archive, member, staging_root, reserve_bytes, progress
                                )
                                logical = Path(member.filename.replace("\\", "/"))
                                item = inspect_source(
                                    staged, args.deep_media_check, progress, logical,
                                    member.date_time[0] if member.date_time else None, digest,
                                )
                                item.source = f"{plan.path}::{member.filename}"
                                if item.valid and item.format in IMAGE_FORMATS:
                                    progress.set_stage("ZIP_IMAGE_SIMILARITY", label)
                                    embedding = attach_image_features(item, staged, embedding_engine)
                                classify_item(
                                    item, destination_index, seen, summary, image_index, embedding,
                                    args.phash_threshold, args.dhash_threshold, args.whash_threshold,
                                    args.embedding_threshold, args.review_only_near,
                                )
                                item.planned_destination = str(choose_target(roots[item.route], item, reserved_targets))
                                if item.route == "unique":
                                    seen[item.sha256] = item.planned_destination
                                progress.set_stage("ZIP_MEMBER_FINALIZE", label)
                                status, moved_bytes = finalize_staged_member(
                                    staged, Path(item.planned_destination), item.sha256, reserve_bytes, progress
                                )
                                staged = None
                                item.status = status
                                if item.route == "review":
                                    count_review(summary, item, moved_bytes)
                                    archive_ok = False
                                    failure_reasons.append(f"Review required for {member.filename}; original ZIP retained")
                                    item.status = "REVIEW_COPIED_ZIP_RETAINED"
                                else:
                                    count_success(summary, item, moved_bytes, "EXISTING" in status)
                                summary.zip_members_finalized += 1
                                if item.route == "unique":
                                    destination_index.setdefault(item.sha256, []).append(item.planned_destination)
                                    if item.phash:
                                        image_index.add_pending(item, item.planned_destination, embedding)
                                        image_index.confirm_pending(item.planned_destination)
                                if item.phash:
                                    image_index.record_item(item, item.planned_destination, embedding)
                                archive_member_items.append(item)
                                items.append(item)
                                progress.moved(moved_bytes)
                                logging.info("ZIP MEMBER FINALIZED %s -> %s [%s]", item.source, item.planned_destination, item.route)
                            except InterruptedError:
                                if item is None:
                                    item = Inspection(source=f"{plan.path}::{member.filename}", size=member.file_size, status="INTERRUPTED")
                                    items.append(item)
                                item.status = "INTERRUPTED_ZIP_RETAINED"
                                archive_ok = False
                                failure_reasons.append(f"Interrupted at {member.filename}")
                                raise
                            except Exception as exc:
                                archive_ok = False
                                failure_reasons.append(f"{member.filename}: {type(exc).__name__}: {exc}")
                                if item is None:
                                    item = Inspection(
                                        source=f"{plan.path}::{member.filename}", size=member.file_size,
                                        format=Path(member.filename).suffix.lstrip(".").upper() or "UNKNOWN",
                                        naming_group=naming_group(Path(member.filename), Path(member.filename).suffix.lstrip(".").upper()),
                                    )
                                    items.append(item)
                                item.status = "FAILED_ZIP_RETAINED"
                                item.error = failure_reasons[-1]
                                summary.failed += 1
                                progress.failed()
                                logging.error("ZIP member failed; archive retained %s: %s", plan.path, exc)
                                if "Insufficient free space" in str(exc):
                                    raise OSError(str(exc))
                            finally:
                                if staged is not None:
                                    try:
                                        staged.unlink(missing_ok=True)
                                    except OSError:
                                        pass
                except InterruptedError:
                    summary.zip_archives_retained += 1
                    items.append(make_archive_control(plan.path, "ZIP_RETAINED_INTERRUPTED", "; ".join(failure_reasons)))
                    raise
                except OSError as exc:
                    summary.zip_archives_retained += 1
                    items.append(make_archive_control(plan.path, "ZIP_RETAINED_STORAGE_OR_IO_FAILURE", str(exc)))
                    raise
                except Exception as exc:
                    archive_ok = False
                    failure_reasons.append(f"Archive read failure: {type(exc).__name__}: {exc}")

                if archive_ok and len(archive_member_items) == len(plan.members):
                    if _stop_requested.is_set():
                        summary.zip_archives_retained += 1
                        items.append(make_archive_control(plan.path, "ZIP_RETAINED_INTERRUPTED", "Interrupted before ZIP deletion"))
                        raise InterruptedError("Interrupted before ZIP deletion")
                    try:
                        plan.path.unlink()
                        summary.zip_archives_deleted += 1
                        summary.source_files_deleted += len(plan.members)
                        for item in archive_member_items:
                            item.source_deleted = True
                            item.status = "MOVED_ZIP_MEMBER_VERIFIED"
                        logging.info("ZIP DELETED after all %d members finalized: %s", len(plan.members), plan.path)
                    except Exception as exc:
                        summary.zip_archives_retained += 1
                        summary.failed += 1
                        reason = f"All members finalized but ZIP deletion failed: {type(exc).__name__}: {exc}"
                        items.append(make_archive_control(plan.path, "ZIP_RETAINED_DELETE_FAILED", reason))
                        logging.error("%s", reason)
                else:
                    summary.zip_archives_retained += 1
                    for member_item in archive_member_items:
                        if member_item.route != "review":
                            member_item.status = "FINALIZED_BUT_ZIP_RETAINED"
                    reason = "; ".join(failure_reasons) or "Not every eligible member finalized"
                    items.append(make_archive_control(plan.path, "ZIP_RETAINED_MEMBER_FAILURE", reason))
                    logging.error("ZIP retained because one or more members failed or need review: %s", plan.path)

    except InterruptedError as exc:
        summary.interrupted = True
        fatal_error = str(exc)
        logging.warning("Run interrupted safely; current source/ZIP retained: %s", exc)
        for item in items:
            if item.status == "PLANNED":
                item.status = "NOT_MOVED_INTERRUPTED"
    except Exception as exc:
        fatal_error = f"{type(exc).__name__}: {exc}"
        logging.error("Run stopped safely: %s", fatal_error)
        if not items:
            summary.failed += 1
    finally:
        if not args.dry_run:
            cleanup_stale_temp_files((destination, duplicates, corrupted, review_needed))
        summary.source_files_retained = max(0, summary.source_files - summary.source_files_deleted)
        summary.elapsed_seconds = time.monotonic() - started_mono
        summary.finished_at = iso_now()
        write_reports(report_dir, items, summary, config)
        if image_index is not None:
            image_index.close()
        progress.close()
        logging.info("Run finished. Reports: %s", report_dir)

    print("\nFinal summary")
    print(f"  Successful unique: {summary.moved_successful} files / {format_bytes(summary.successful_bytes)}")
    print(f"  Duplicates:        {summary.moved_duplicates} files / {format_bytes(summary.duplicate_bytes)}")
    print(f"    EXACT_SHA256:    {summary.exact_sha256_duplicates}")
    print(f"    PHASH_NEAR:      {summary.phash_near_duplicates}")
    print(f"    DHASH_NEAR:      {summary.dhash_near_duplicates}")
    print(f"    WHASH_NEAR:      {summary.whash_near_duplicates}")
    print(f"  Review needed:     {summary.review_needed} files / {format_bytes(summary.review_bytes)}")
    print(f"  Corrupted:         {summary.moved_corrupted} files / {format_bytes(summary.corrupted_bytes)}")
    print(f"  Failed:            {summary.failed}")
    print(f"  ZIP deleted:       {summary.zip_archives_deleted}")
    print(f"  ZIP retained:      {summary.zip_archives_retained}")
    print(f"  Elapsed:           {format_duration(summary.elapsed_seconds)}")
    print(f"  Reports:           {report_dir}")
    if fatal_error:
        print(f"  Stop reason:       {fatal_error}")
    if summary.interrupted:
        return 130
    if fatal_error:
        return 4
    return 1 if (summary.failed or summary.review_needed) else 0


if __name__ == "__main__":
    raise SystemExit(main())
