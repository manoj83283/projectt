# Verified Directory Tree Mover

This is an independent tool for one job only: **move an entire directory tree while preserving every relative folder and filename exactly**.

It does not convert, rename, reorganize, deduplicate, classify, or inspect media semantics.

## Windows quick start

1. Extract the package.
2. Open `VerifiedTreeMover`.
3. Double-click `run_verified_tree_move.bat`.
4. Enter the source tree and destination root.

The BAT detects Python 3.10+, attempts a current-user Python installation through Windows Package Manager if needed, creates its own `.venv`, and starts `verified_tree_move.py`. It shares no environment with the HEIC converter.

## Exact structure preservation

If Source contains:

```text
D:\Source\Project\Photos\image.jpg
D:\Source\Project\notes.txt
```

and Destination is `E:\Archive`, outputs are:

```text
E:\Archive\Project\Photos\image.jpg
E:\Archive\Project\notes.txt
```

Names and relative paths are not changed.

## Per-file verified move sequence

For every ordinary file:

1. calculate source SHA-256;
2. create the exact destination parent folders;
3. copy into a target-local name such as `.filename.<UUID>.vtm.part`;
4. flush and `fsync` the part file;
5. compare the streaming hash and source hash;
6. independently hash the part file;
7. atomically rename the part to the final filename;
8. independently hash the final destination;
9. delete the source only after all hashes agree.

The source is retained on capacity shortage, interruption, read/write error, hash mismatch, destination conflict, or any other failure.

## Destination conflicts and resume

- If the exact destination filename exists with different content, it is never overwritten; the source remains and the conflict is reported.
- If the destination exists with the same SHA-256, it is treated as a verified completed copy. The source is then deleted, allowing safe resume after a previous interruption that occurred after finalization.
- Only temporary files matching this tool's strict UUID `.vtm.part` pattern are removed on startup/shutdown recovery. Other `.part` files are untouched.

## Capacity and layout safety

The tool pre-scans all source files, totals missing-destination bytes, checks destination free space, and maintains a configurable reserve. It also checks space before each file.

Source and destination must be separate, non-overlapping directory trees. Symlinks are skipped.

Default reserve: 512 MiB.

```bat
run_verified_tree_move.bat --reserve-mb 1024
```

## Empty directory removal

After all file operations, directories are considered bottom-up. A source directory is removed only when it is empty. Any failed file, conflict, skipped entry, or other content keeps that directory and its ancestors in place.

## Live progress and heartbeat

The console and `transfer.log` show current directory/file and stage, processed count, bytes read/written, rate, elapsed time, and ETA when calculable.

An independent heartbeat is emitted every 30 or 60 minutes even during one large file:

```bat
run_verified_tree_move.bat --heartbeat-minutes 30
```

## Dry run and command line

```bat
run_verified_tree_move.bat ^
  --source "D:\SourceTree" ^
  --destination "E:\DestinationRoot" ^
  --reserve-mb 512 ^
  --heartbeat-minutes 30
```

Planning only:

```bat
run_verified_tree_move.bat --source "D:\SourceTree" --destination "E:\DestinationRoot" --dry-run
```

Options:

- `--source PATH`
- `--destination PATH`
- `--reserve-mb N`
- `--heartbeat-minutes 30|60`
- `--report-dir PATH`
- `--dry-run`
- `--verbose`
- `--help`

## Reports

By default each run writes under:

```text
Destination/.verified_tree_move/reports/<run-id>/
```

Files:

- `final_report.txt` — counts, bytes, capacity, elapsed time, directory removal, interruption state;
- `files.csv` — source, relative path, destination, hashes, status, deletion state, bytes, error;
- `summary.json` — machine-readable summary and configuration;
- `transfer.log` — operations, progress, heartbeats, warnings, and failures.

Exit codes: `0` success, `1` completed with retained/failed files, `4` safe fatal/preflight stop, `130` safe interruption.

Keep an independent backup of irreplaceable data before any move operation.
