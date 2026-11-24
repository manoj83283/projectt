# Two Independent File Tools

This package contains two separate tools. They have different Python scripts, requirements, virtual environments, BAT launchers, READMEs, logs, and reports.

## 1. VerifiedTreeMover

Moves an entire directory tree without changing its structure or filenames. It does not perform media conversion, deduplication, classification, or renaming.

Start: `VerifiedTreeMover/run_verified_tree_move.bat`

## 2. HeicConverter

Recursively converts HEIC/HEIF images to JPG or PNG while preserving folder structure and metadata where supported. It defaults to preserving originals and supports safely streamed ZIP-contained HEIC images.

Start: `HeicConverter/run_heic_converter.bat`

Read the README inside each tool directory before running it. Neither tool calls the other or depends on the other tool's environment.
