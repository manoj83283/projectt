# Safe Media Transfer Toolkit 4.0

A Windows-friendly verified mover and ZIP streamer with **fully local layered image-duplicate detection**. It organizes content as `FORMAT/YEAR/NAMING_GROUP`, keeps one canonical image in Destination B, routes confirmed copies to `Duplicates`, and sends uncertain image matches to `REVIEW_NEEDED` without deleting their ordinary source.

No image is uploaded and no cloud inference service is used.

## Quick start

1. Extract the complete toolkit ZIP.
2. Double-click **`run_media_transfer.bat`**.
3. The launcher detects or installs Python 3.12, creates `.venv`, and installs the packages in `requirements.txt`.
4. The launcher offers the larger optional local embedding packages. Decline for fast CPU hash mode, or install them for crop/mirror/watermark review detection.
5. Enter:
   - **Source A** — recursively scanned ordinary files and ZIP archives;
   - **Destination B** — unique/canonical files;
   - **Exception root** — parent under which the toolkit creates `Duplicates`, `Corrupted`, and `REVIEW_NEEDED`.

## Output hierarchy

```text
Destination B/
  JPG/2026/IMG/IMG_0001.jpg
  PNG/2025/SCREENSHOTS/Screen Shot 2025.png
  .media_transfer/
    metadata/image_index.sqlite3
    reports/<run-id>/
      files.csv
      final_report.txt
      summary.json
      transfer.log

Exception root/
  Duplicates/FORMAT/YEAR/NAMING_GROUP/files
  Corrupted/FORMAT/YEAR/NAMING_GROUP/files
  REVIEW_NEEDED/FORMAT/YEAR/NAMING_GROUP/files
```

Naming groups include `IMG`, `SCREENSHOTS`, common camera/media prefixes, `NUMERIC`, sanitized alphabetic prefixes, and safe fallback groups. Collisions use a short SHA-256 suffix and serial number. Existing different files are never overwritten.

## Layered image matching

The pipeline runs locally in this order:

1. **EXACT_SHA256** — byte-identical content. Automatically routes the additional copy to `Duplicates`.
2. **pHash, dHash, and wHash** — three independent 64-bit perceptual hashes computed from EXIF-normalized pixels with Pillow and NumPy.
   - pHash uses a 32×32 DCT and an 8×8 low-frequency fingerprint.
   - dHash uses adjacent grayscale differences.
   - wHash uses Haar-style low-frequency averaging.
3. **Optional local embeddings** — MobileNetV3-Small features from TorchVision, normalized and searched by local cosine nearest-neighbor comparison (a NumPy equivalent of a flat inner-product/FAISS index).

Conservative default automatic near-duplicate routing requires:

- pHash distance ≤ `4`; and
- dHash distance ≤ `3` **or** wHash distance ≤ `4`; and
- aspect-ratio difference ≤ 20%.

Strong matches route to `Duplicates`. A one-hash/weak perceptual match is copied to `REVIEW_NEEDED` and its ordinary source is retained. An embedding-only score ≥ `0.94` is labeled `EMBEDDING_REVIEW`, copied to `REVIEW_NEEDED`, and its ordinary source is retained. Embeddings never cause automatic source deletion.

Use `--review-only-near` to send even strong perceptual near matches to review while retaining their ordinary source. Exact SHA-256 duplicates remain confirmed and automatically route to `Duplicates`.

### Threshold options

```bat
run_media_transfer.bat ^
  --phash-threshold 4 ^
  --dhash-threshold 3 ^
  --whash-threshold 4 ^
  --embedding-threshold 0.94
```

Lower Hamming thresholds and a higher embedding threshold are more conservative. Valid Hamming values are 0–64; embedding cosine threshold is -1 to 1.

## Optional embedding mode

Run:

```bat
run_media_transfer.bat --enable-embeddings
```

The BAT launcher installs `requirements-embeddings.txt` when needed. The program uses CPU-local TorchVision MobileNetV3-Small. TorchVision may download the official model weights once on first use; afterward inference is local and the weights are cached. Images are never uploaded.

Embedding mode is optional because Torch/TorchVision are large. Core SHA-256 plus pHash/dHash/wHash mode requires only `requirements.txt` and works on CPU-only machines.

## Persistent SQLite image index

The default database is:

```text
Destination B/.media_transfer/metadata/image_index.sqlite3
```

Override it with `--metadata-dir PATH`.

The `image_index` table stores:

- source and final paths;
- size and modification time;
- SHA-256;
- width and height;
- pHash, dHash, and wHash;
- optional float32 embedding and local index/row ID;
- canonical/original path;
- duplicate reason;
- all perceptual distances and embedding cosine score;
- selected action;
- run ID and update time.

Destination B is synchronized against this index at startup. Unchanged files reuse cached fingerprints; changed/new canonical images are recalculated. Repeated runs therefore compare new images against established canonical files.

## Canonical and review behavior

- The first unique image is finalized in Destination B and becomes canonical.
- Additional exact or safely confirmed perceptual copies go to `Duplicates/FORMAT/YEAR/NAMING_GROUP`.
- If a planned canonical fails to finalize, dependent matches are promoted to canonical instead of leaving only duplicate copies.
- Weak or embedding-only matches are copied to `REVIEW_NEEDED`; ordinary source files remain in Source A.
- `files.csv` records `duplicate_type`, `matched_canonical_path`, all distances/scores, and `selected_action`.

## Verified ordinary-file move

For a normal unique, confirmed duplicate, or corrupted file, the toolkit:

1. inspects and hashes the source;
2. writes to a target-local UUID `.part`;
3. flushes and `fsync`s it;
4. verifies SHA-256;
5. atomically renames it;
6. verifies the final file again;
7. only then deletes the source.

On interruption, storage shortage, read/write error, validation failure, hash mismatch, or any error, the source remains. Review items use the same verified finalization but intentionally retain the ordinary source.

## ZIP processing

- ZIP archives are scanned recursively from Source A.
- Members are never permanently extracted to a staging tree.
- Each regular-file member streams to a toolkit UUID `.part`, is validated, hashed, image-compared, classified, and finalized.
- Encrypted/unreadable members fail safely.
- Temporary files are removed after success, failure, interruption, and next-run recovery.
- The source ZIP is deleted only when **every eligible member** is finalized with no review requirement.
- A failed, interrupted, storage-short, unreadable, empty, or review-needed ZIP is retained with the exact reason in reports.
- If an embedding/weak near match from a ZIP goes to `REVIEW_NEEDED`, the ZIP is retained so the uncertain original is not destroyed.
- Nested ZIP members are finalized as ZIP files; their own members are not recursively expanded.

## Format validation and year selection

Format uses recognized signatures when available, otherwise the original extension/member name. Validation includes supported images, PDF, ZIP/Office containers, gzip/bzip2/xz/tar, JSON, XML/SVG, SQLite, and common media containers. Unknown formats receive a full readability and SHA-256 pass.

Year selection considers embedded image/PDF/document/media metadata, filename, member/parent path, ZIP timestamp, and ordinary modification time.

## Storage and interruption safety

The preflight calculates ordinary requirements and declared ZIP uncompressed sizes. Because ZIP routing is unknown before validation, it reserves ZIP bytes conservatively on every possible target volume plus the largest member on the staging volume. A 5% or 100 MiB margin, whichever is larger, is required by default. Free space is checked again per file/member.

`--allow-partial` overrides only aggregate preflight; per-item checks remain mandatory.

A visible/logged heartbeat runs independently every 30 or 60 minutes:

```bat
run_media_transfer.bat --heartbeat-minutes 30
```

Live progress includes stage, current directory/file/archive/member, discovered/processed counts, bytes read/moved, rate, elapsed time, and ETA when calculable.

## Dry run

```bat
run_media_transfer.bat ^
  --source "D:\Input" ^
  --destination "E:\Organized" ^
  --exception-root "F:\Media Exceptions" ^
  --dry-run
```

Dry run scans directories and ZIP central directories, hashes/classifies ordinary files, computes image similarities, synchronizes the metadata index, and performs capacity planning. It does not stream ZIP members, move/copy content, or delete sources.

## Full example

```bat
run_media_transfer.bat ^
  --source "D:\Camera Dump" ^
  --destination "E:\Organized" ^
  --exception-root "F:\Media Exceptions" ^
  --reserve-mb 500 ^
  --heartbeat-minutes 30 ^
  --enable-embeddings ^
  --deep-media-check
```

## Reports

Every run writes:

- `files.csv` — per ordinary file, ZIP member, and archive-control event, including duplicate type, canonical, pHash/dHash/wHash distances, embedding score, action, route, target, validation, status, and error;
- `final_report.txt` — unique, corrupted, review, failure, byte, elapsed-time, source-retention, ZIP, `EXACT_SHA256`, `PHASH_NEAR`, `DHASH_NEAR`, `WHASH_NEAR`, and `EMBEDDING_REVIEW` counts;
- `summary.json` — machine-readable totals, settings, thresholds, paths, and capacity data;
- `transfer.log` — detailed actions, progress, heartbeat, errors, and ZIP retention/deletion reasons.

Exit codes:

- `0` — completed with no failures/review items;
- `1` — completed with review-needed or item/archive failures;
- `4` — fatal configuration/capacity/I/O safety stop;
- `130` — interrupted safely.

## Operational notes

- Keep an independent backup before a move operation.
- Symlinks are skipped.
- Password-protected ZIP members are not decrypted.
- ZIP member paths are never recreated, preventing path traversal; only safe basenames are finalized.
- Never overlap Source A with Destination B, Duplicates, Corrupted, or REVIEW_NEEDED.
- Similarity is probabilistic. Review the `REVIEW_NEEDED` directory and report; do not raise thresholds aggressively without testing on representative images.
