# OctoPrint docs: Getting Started (main/dev docs)

Source URL(s): https://docs.octoprint.org/en/main/gettingstarted.html · landing https://docs.octoprint.org/en/main (intro only) · bundled plugins index and configuration index also fetched (TOC only, no facts) · fetched 2026-11-26

## Requirements
- Python 3.9 or newer, plus pip and virtualenv. Listed versions run 3.9 through 3.15.

## Install (source/pip)
- `virtualenv venv` (optional `--python=python3`); `./venv/bin/pip install OctoPrint`; run `/path/to/OctoPrint/venv/bin/octoprint`. Run as a normal user, not sudo.
- Other: OctoPi (Raspberry Pi image); Docker not mentioned.

## Run
- `octoprint serve`; `--host=127.0.0.1 --port=8080` overrides (also in config file).
- Flags: `--config` (custom config file), `--basedir` (base dir holding uploads, timelapse, logs), `--safe` (disable third-party plugins).
- Linux daemon: `octoprint daemon {start|stop|restart} [--pid PIDFILE]` (default pidfile /tmp/octoprint.pid).
- Default port: 5000, all interfaces.
- First run: setup wizard; configure access control.

## Config / base folder
- Settings folder holds `config.yaml`.
- Linux default: `~/.octoprint`; Windows `%APPDATA%/OctoPrint`; macOS `~/Library/Application Support/OctoPrint`.
- Config reference page: config.yaml sections (Server, Folder, Serial, Webcam, etc.); logging.yaml; CLI page.

## Gotchas
- Docs are for main (dev), not latest release.
