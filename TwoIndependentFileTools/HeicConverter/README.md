# Recursive HEIC/HEIF to JPG/PNG Converter

This is an independent conversion tool only. It recursively converts Apple HEIC/HEIF images to Android-compatible JPEG or PNG while preserving relative folder structure. It does not move arbitrary directory trees, deduplicate, classify, or reorganize files.

## Windows quick start

1. Extract the package.
2. Open `HeicConverter`.
3. Double-click `run_heic_converter.bat`.
4. Enter the HEIC source root and a separate output root.

The BAT detects or installs Python 3.10+, creates this tool's own `.venv`, and installs maintained open-source packages from its own `requirements.txt`:

- Pillow;
- pillow-heif with libheif support;
- piexif.

It shares no environment with the directory-tree mover.

## Folder preservation

```text
Source/nested/holiday.heic
  -> Output/nested/holiday.jpg
```

For ZIP members, the archive name is represented as a safe container directory:

```text
Source/trip.zip :: phone/DCIM/IMG_0001.heic
  -> Output/trip__ZIP/phone/DCIM/IMG_0001.jpg
```

ZIP member paths are sanitized against `..` traversal.

## Output choices

JPEG, quality 92:

```bat
run_heic_converter.bat --format jpg --jpeg-quality 92
```

PNG:

```bat
run_heic_converter.bat --format png
```

JPEG quality must be 1–100. It is ignored for PNG.

## Metadata and validation

The converter:

- decodes and fully loads the HEIC/HEIF source;
- applies EXIF orientation to pixels;
- resets output orientation to 1;
- preserves available EXIF metadata, including capture date, when supported by the output encoder;
- preserves an ICC color profile when available and supported;
- validates generated format and dimensions;
- writes to a UUID `.heicconv.part` in the final target directory;
- flushes and `fsync`s it;
- hashes it, atomically finalizes it, hashes the final file, and validates it again.

pillow-heif/libheif is the normal HEIC backend. If it is unavailable but local ImageMagick is installed, the Python program has a local fallback decoder; metadata preservation may be more limited in fallback mode. No cloud service is used.

## Original preservation and deletion

**Default:** originals are always preserved.

Explicit deletion requires both options exactly:

```bat
run_heic_converter.bat ^
  --delete-originals ^
  --confirm-delete DELETE-HEIC-AFTER-VERIFIED-CONVERSION
```

An ordinary HEIC/HEIF source is deleted only after its converted output is decoded, flushed, atomically finalized, SHA-256 verified, and validated.

The original is retained on output conflict, storage shortage, interruption, decode/encode error, hash mismatch, corrupt input, or any failure.

### ZIP deletion rule

A source ZIP is deleted in confirmed deletion mode only if:

- every regular member is HEIC/HEIF;
- every member converts and verifies successfully;
- no output conflict/failure/interruption occurs.

A ZIP containing non-HEIC files is always retained. A failed or corrupt member also retains the entire ZIP. In default mode, every ZIP is retained.

## Output conflicts and repeated runs

Existing output files are never overwritten. A second source that maps to the same output name—for example `photo.heic` and `photo.heif`—causes an explicit conflict for the later file. That source remains.

Repeated runs safely report already-existing outputs as conflicts and preserve originals. Choose a new output root or resolve conflicts manually.

## Corrupted routing

An ordinary HEIC/HEIF that cannot decode is preserved at its source and, when its raw bytes remain readable, a verified copy is placed under:

```text
Output/CorruptedHEIC/<original relative path>
```

A corrupt ZIP member is similarly routed under an archive `__ZIP` folder while the original ZIP remains. Routing never overwrites an existing file.

## Safe ZIP streaming

ZIP members are streamed directly into toolkit-managed temporary `.heicconv.part` files under the output metadata directory. There is no permanent extraction/staging tree. Each temporary member is removed after success, failure, interruption, and next-run recovery.

Encrypted/unreadable members fail safely and retain the original archive.

## Capacity, progress, and heartbeat

The converter pre-scans ordinary HEIC and declared ZIP-member sizes. It uses a conservative estimate of 2× source bytes for JPEG or 6× for PNG, plus the configured reserve. Free space is checked again before temporary streaming and output generation.

Live console/log progress includes current directory/file/archive/member, stage, processed count, bytes read/output, rate, elapsed time, and ETA.

```bat
run_heic_converter.bat --reserve-mb 512 --heartbeat-minutes 30
```

## Dry run

```bat
run_heic_converter.bat ^
  --source "D:\Apple Photos" ^
  --output "E:\Android Photos" ^
  --format jpg ^
  --jpeg-quality 92 ^
  --dry-run
```

Dry run scans ordinary files and ZIP central directories, plans output paths, and checks capacity. It does not decode members, write output, route corrupt files, or delete originals.

## Reports

Each run writes under:

```text
Output/.heic_converter/reports/<run-id>/
```

- `final_report.txt` — found, converted, corrupt, conflict, failed, source/ZIP preservation/deletion, byte, capacity, and elapsed totals;
- `files.csv` — per ordinary file and ZIP member, metadata preservation flags, dimensions, hashes, status, and error;
- `summary.json` — machine-readable totals and settings;
- `transfer.log` — detailed progress, heartbeat, conversion, and safety events.

Exit codes: `0` success, `1` completed with conflicts/failures, `4` safe preflight/fatal stop, `130` safe interruption.

Keep backups before using confirmed deletion mode.
