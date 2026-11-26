# JakeWharton/mkvdts2ac3

Source URL(s) + fetch date:
- https://github.com/JakeWharton/mkvdts2ac3 (repo; tagged 1.6.0 per plan)
- https://raw.githubusercontent.com/JakeWharton/mkvdts2ac3/1.6.0/mkvdts2ac3.sh (fetched 2026-11-26)
- https://raw.githubusercontent.com/JakeWharton/mkvdts2ac3/1.6.0/README.md (fetched 2026-11-26; the summary states "v1.5.3", see gotchas)
- https://raw.githubusercontent.com/JakeWharton/mkvdts2ac3/1.6.0/LICENSE.txt (fetched 2026-11-26)
- Tarball (not downloaded, binary archive): https://github.com/JakeWharton/mkvdts2ac3/archive/refs/tags/1.6.0.tar.gz

## What it is

Bash script that converts DTS audio tracks inside Matroska (MKV) files to AC3 (6 channels, 448 kbps via ffmpeg `-acodec ac3 -ac 6 -ab 448k`), then remuxes with mkvmerge. Default behavior: takes first DTS track, converts, adds AC3 to the file, and overwrites the original MKV (unless `--new`).

## Install/build steps and build deps

- No build. Copy `mkvdts2ac3.sh` into a PATH dir (`install -m 0755`). Optional `LICENSE.txt`.
- Release archive pattern: GitHub tag archive `archive/refs/tags/<tag>.tar.gz` (tag `1.6.0`, no `v` prefix). Extract with `--strip-components=1`; top-level dir contains `mkvdts2ac3.sh` and `LICENSE.txt`.

## Runtime deps

Checked via `checkdep` (only when not `--test`): `mkvmerge`, `mkvextract`, `mkvinfo` (mkvtoolnix), `ffmpeg`, `rsync`, `perl`. Also uses `nice`, `du`, `df`, `md5sum`, `sed`, `awk`, `grep`, `cut`, `which`.

Requirements per README: mkvtoolnix, ffmpeg, rsync.

## Binaries/entrypoint/CLI flags

Usage: `mkvdts2ac3.sh [options] <filename>`

| Flag | Meaning (from script help) |
| --- | --- |
| `-c TITLE`, `--custom TITLE` | custom AC3 track title |
| `-d`, `--default` | mark AC3 track as default (adds `--default-track 0`) |
| `-e`, `--external` | leave AC3 out of file; original untouched; overrides `-n` and `-d` |
| `-f`, `--force` | process even if an AC3 track is detected |
| `-i`, `--initial` | new AC3 track first in file |
| `-k`, `--keep-dts` | keep DTS as external file (implies `-n`) |
| `-m`, `--nocolor` | no colors |
| `--md5` | MD5 compare when copying across drives |
| `-n`, `--no-dts` | drop the DTS track from the remux (if only audio, uses `-A`) |
| `--new` | write new adjacent file `NAME-AC3.mkv` instead of replacing |
| `-p PRIORITY` | niceness of executed commands (default 0) |
| `-s MODE`, `--compress MODE` | mkvmerge `--compression` applied to video, kept audio and new AC3 (default `none`) |
| `-t TRACKID`, `--track TRACKID` | alternate DTS track (find IDs with `mkvmerge -i`) |
| `-w FOLDER`, `--wd FOLDER` | temp working dir (default `/tmp`) |
| `--test` | print commands only, execute nothing (skips checkdep) |
| `--debug` | print commands and pause before each |
| `-h`, `--help`, `-v`, `--verbose`, `-V`, `--version` | help / verbose / version |

User defaults: `~/.mkvdts2ac3.rc` is sourced if present (vars `EXTERNAL`, `NODTS`, `KEEPDTS`, `DEFAULT`, `FORCE`, `INITIAL`, `NOCOLOR`, `MD5`, `NEW`, `PRIORITY`, `DTSTRACK`, `DTSNAME`, `COMP`).

Output naming:
- Temp files in `$WD`: `NAME.dts`, `NAME.ac3`, `NAME.tc`, `NAME.new.mkv`.
- Default: new mux replaces original MKV.
- `--new`: `$DEST/NAME-AC3.mkv`.
- `-e`: `$DEST/NAME.ac3` only.
- `-k`: also copies DTS to MKV folder as `NAME.dts`.

## Env vars

None (script reads `~/.mkvdts2ac3.rc` only). The Hub image's `script`/`parameters`/`mkvdts2ac3_params` env vars are container-level (see dockerhub file).

## Ports

None.

## Volumes/paths and persistent data

- Works on the MKV in place; `WD=/tmp` unless `-w`. Cross-device copies use rsync.

## User/UID & permissions

- None set by script.

## Config files and formats

- `~/.mkvdts2ac3.rc` (shell variables).

## Healthcheck/readiness endpoints

None (CLI script).

## Version/release info and asset naming

- Tag 1.6.0 used by plan (`MKVDTS2AC3_VERSION` 1.6.0). Script version reported by `-V`. Tag archive pattern as above. No checksum published upstream.

## Arch support

Arch independent shell script. README notes Mac OS X users may need to build deps.

## License

- Apache License, Version 2.0 (LICENSE.txt at 1.6.0: "Apache License, Version 2.0, January 2004"). Script copyright 2011 Jake Wharton (per README). Authors: Jake Wharton, Chris Hoekstra.

## Gotchas

- The README returned for tag 1.6.0 describes itself as "mkvdts2ac3 (v1.5.3)". Either the README is stale or the fetch summary is inaccurate; the script itself reports its own version via `-V` (not fetched). Treat the script at the pinned tag as the authority.
- The `-d` flag makes the AC3 default; it does NOT drop DTS. `-n` drops DTS.
- `--new` creates a new file; it does not overwrite.
- Without `-w`, temp files go to `/tmp` and can fill it for large files.

## Contradictions with plan.md

- plan.md section 1 says `-d` = "drop DTS" and `-n` = "no AC3 if present?". Script help: `-d` = AC3 default; `-n` = drop the DTS track. Corrected in plan.md.
- plan.md section 1 says `--new` meaning is UNVERIFIED. Confirmed: writes `NAME-AC3.mkv` next to the original.
- plan.md section 1: `mkvdts2ac3.sh` needs `mkvmerge`, `mkvextract`, `ffmpeg`, `rsync`, `du`, `nice`, `perl`. Confirmed (`checkdep` covers mkvinfo and perl too).
