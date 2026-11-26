# danmed/TasmoBackupV1 README (summary)

Source URL: https://raw.githubusercontent.com/danmed/TasmoBackupV1/master/README.md (fetched 2026-11-26; also covers https://github.com/danmed/TasmoBackupV1 repo root)

## What it is
- Backs up Tasmota device configs; also WLED and OpenBeken.
- Add/discover/backup/remove/download; bulk select; console command to multiple devices.
- Backups can be locked against pruning. Duplicates matched by MAC, then hostname, then IP.
- Gettext translations (28 catalogues); optional debug logging.

## Device specifics
- WLED: backup = zip of cfg.json + presets.json; discovery by IP scan only.
- OpenBeken: JSON from `/api/pins`, startup command, `/api/info`; restore posts to `/api/pins` (no reboot); IP scan discovery.
- Tasmota32 Berry: `.be` files present -> zip with config.dmp + files/; else plain .dmp.

## Install options
- HA Supervisor: add repo `http://github.com/danmed/TasmoBackupV1` in Add-On Store.
- Docker Compose / docker run (see Docker Hub summary).
- Raw PHP: `git clone`; `mkdir data`; `chown www-data data`; `cp config.inc.php.example data/config.inc.php`; edit for MySQL if needed; run `upgrade.php`. Data dir must be owned by PHP user.

## Config / data paths
- Container data dir: `/var/www/html/data`; raw PHP `./data`.
- Config: `data/config.inc.php` (from `config.inc.php.example`).
- SQLite DB: `data/tasmobackup`.
- Translations: `locale/<lang>/LC_MESSAGES/tasmobackup.po`, template `locale/tasmobackup.pot`. Image compiles .mo at build.

## Scheduling
- Run `backupall.php` on schedule (Node-RED, curl, etc.).

## Dev
- `make test`, `make test-live`, `make build` (qemu), `make buildx`, `make pot`/`update-po`/`mo`.

## Not stated
- Container process user/UID; PHP version requirement; license.
