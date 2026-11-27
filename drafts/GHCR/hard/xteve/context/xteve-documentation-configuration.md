# xTeVe-Documentation: configuration

Source URL(s) + date: https://raw.githubusercontent.com/xteve-project/xTeVe-Documentation/master/en/configuration.md (github blob variant same) (fetched 2026-11-27)

## Run
- Binary: `xteve`; run as `./xteve` on Linux/OS X/FreeBSD (chmod +x first).
- Windows: `xteve.exe`; service via NSSM (not relevant to container).

## CLI options
| Flag | Meaning |
| --- | --- |
| -config=<path> | config folder path |
| -port="XXXX" | listen port (doc example; default is 34400 per console sample) |

## Console sample (doc, v2.0.0 era)
- System Folder: `~/.xteve/` (stores all config files; `settings.json` loaded from there).
- Temporary folder: `/tmp/xteve/<UUID>/` (per-instance).
- Web interface: `http://<ip>:34400/web/`.

## Config sections (doc index)
- Playlist, Filter, XMLTV, Mapping, Users, Settings, Log; API (see doc). Migration 1.4.4 -> 2.x.x covered in doc.
- M3U export available.

## Gotchas
- Doc is from 2.0.0 era; the console sample shows version 2.0.0 while the chart runs 2.2.0.200.
- Default system folder in container depends on the image (not fetched).
