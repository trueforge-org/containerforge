# Upstream wiki: rembo10/headphones

Source URLs (fetched 2026-11-27):
- https://github.com/rembo10/headphones/wiki (Home)
- https://github.com/rembo10/headphones/wiki/Installation
- https://github.com/rembo10/headphones/wiki/Usage-guide

Wiki pages not fetched: Headphones VIP Server Information, Install as a daemon, Musicbrainz mirrors, Setting Up a Local Musicbrainz Mirror, Troubleshooting, XLD Re Encoding on OSX.

## Install (non-Docker)
- Python 3.6+ (Linux/macOS use `python3`). FreeBSD page says `python2.7` (inconsistent, ignore).
- No pip/requirements commands on the page.
- Git clone: `git clone https://github.com/rembo10/headphones.git` (Linux: run from `/opt`, install path `/opt/headphones`).
- Run: `python3 Headphones.py`.
- Default port 8181 (`http://localhost:8181`).
- Deps mentioned: git only (plus sqlite3 on FreeBSD). ffmpeg, flac, shntool are not mentioned here.
- Config file name, config location, data dir: not stated.

## Usage guide (settings)
- HTTP port default 8181. Host default `localhost`; set `0.0.0.0` for remote access.
- Optional web username/password (restart needed).
- Post-processing folder: download client output; must be writable by both apps. Never point at the final destination.
- Destination folder: used when "Move downloads to Destination Folder" is checked.
- Download methods: direct client (preferred) or Black Hole watch folder.
- Re-encoding: encoder must be on PATH.
- Quality: highest excl. lossless, highest incl. lossless, lossless only, preferred bitrate.
- Newznab host URL for NZB search.

## Gotchas
- No Docker notes on any fetched wiki page.
- Upstream last release v0.6.4 (2025-07-01); image is pinned to the commit archive instead.
