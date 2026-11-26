# GitHub: dazedcat19/FMD2 (application)

Source URL(s) + fetch date (2026-11-26):
- https://github.com/dazedcat19/FMD2 (README via raw `master/README.md`)
- https://api.github.com/repos/dazedcat19/FMD2/releases/latest

## What it is

- Free Manga Downloader 2 ("FMD2"), active fork. Object Pascal, built with Lazarus and Free Pascal.
- Pure native code (no .NET or JVM). Windows builds only (Win32 and Win64).

## Build (from README, not needed for the image)

- Lazarus + FPC; packages Synapse, InternetTools, LCL Extensions, DCPCrypt, RichMemo, MultiLog, VirtualTreeViewV5, MetaDarkStyle, Lazarus_CustomControls.
- Third-party libs (Brotli, Duktape, WebP, Lua, OpenSSL, SQLite, PCRE2, Zstd, lua-protobuf, 7-Zip) are NOT in the source; pre-compiled binaries needed.
- Build: open `md.lpi`, Run -> Build; output in `bin`.

## Run

- Download the 7z for Win32 or Win64 from the latest release.
- Optional CLI args: `--lua-dofile` (dev only), `--no-commit-queue`, `--max-commit-queue`, `--max-flush-queue`, `--max-big-flush-queue`, `--backup-interval`.
- Paths: `languages/` folder (`fmd.xx.po`), `bin/` build output. No install path or userdata/data folder described.
- Lua modules loaded via `--lua-dofile`; module storage location not stated. Lua 5.4.9 bundled.
- No mention of Wine or Linux in this README.

## Version / release info (GitHub API, latest)

- tag_name `2.0.34.5`, published 2025-03-17T14:42:58Z.
- Assets (2 total):
  - `fmd_2.0.34.5_i386-win32.7z` (4,839,434 bytes)
  - `fmd_2.0.34.5_x86_64-win64.7z` (5,268,253 bytes), URL `https://github.com/dazedcat19/FMD2/releases/download/2.0.34.5/fmd_2.0.34.5_x86_64-win64.7z`
- Asset naming pattern: `fmd_<version>_<arch>-win<bits>.7z`. No checksum asset listed.

## License

- README: "released under the GPLv2 license". No "or later" wording, so `GPL-2.0-only` is consistent but not confirmed.

## Arch

- Windows x86 and x86_64 only. No arm64 build exists upstream.

## Gotchas

- Released 2025-03-17; the Docker wrapper pins 2.0.32.0 (see `github-banh-canh-docker-fmd2.md`).
