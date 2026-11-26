# rcon-web-admin/rcon-web-admin (GitHub, maintained fork)

Source URL(s) + fetch date (2026-11-26):
- https://github.com/rcon-web-admin/rcon-web-admin (repo; README via https://raw.githubusercontent.com/rcon-web-admin/rcon-web-admin/master/README.md)
- https://github.com/rcon-web-admin/rcon-web-admin/releases/tag/0.14.1 (release page)
- Not fetched (direct archive, pattern recorded): https://github.com/rcon-web-admin/rcon-web-admin/archive/${VERSION}.tar.gz and .../archive/0.14.1.tar.gz

## What it is
Web interface for controlling RCON servers ("All servers with RCON support should work"). Runs on any always-on device. Maintained fork under rcon-web-admin/rcon-web-admin; the original developer (brainfoolong) stopped maintaining it. Features: unlimited users and servers with granular permissions, HTML/JS widget framework, one-click updates, rcon.web support, core widgets (Console, Autobot, Rustboard, Timed Commands). Tested with Rust, CS:GO and Minecraft.

## Requirements
- NodeJS v12.13.1 (per README). npm for installation. No yarn.

## Install (Linux, README)
```
sudo apt-get install nodejs npm
sudo npm update npm -g
wget https://codeload.github.com/rcon-web-admin/rcon-web-admin/zip/master -O rcon-web-admin.zip
unzip rcon-web-admin.zip
mv rcon-web-admin-master rcon-web-admin
cd rcon-web-admin
npm install
node src/main.js install-core-widgets
chmod 0755 -R startscripts *
```
- Avoid running as root. Do not install into an internet-reachable directory.
- Install CLI: `node src/main.js install-core-widgets` downloads four widgets from GitHub master zips (rwa-autobot, rwa-console, rwa-rustboard, rwa-timedcommands) (per plan.md).

## Run
- Linux: `sh startscripts/start-linux.sh start|stop|restart` (not used by container).
- Container entry per upstream wrapper: `node src/main.js start`.

## Runtime deps (from plan.md, package-lock lockfileVersion 1)
- express ^4.17.1, fstream, lowdb >=0.14.0 (lock pins 0.14.0), unzipper ^0.10.5, ws.

## Env vars (README; defaults)
| Variable | Default |
| --- | --- |
| RWA_ENV | FALSE (enables env config; the itzg wrapper sets TRUE) |
| RWA_USERNAME | admin |
| RWA_PASSWORD | none (required per plan.md: app exits without it) |
| RWA_RESTRICT_COMMANDS | none |
| RWA_RESTRICT_WIDGETS | none |
| RWA_READ_ONLY_WIDGET_OPTIONS | FALSE |
| RWA_ADMIN | FALSE |
| RWA_RCON_HOST | 127.0.0.1 |
| RWA_GAME | minecraft (values minecraft, rust, csgo, other) |
| RWA_SERVER_NAME | value of RWA_GAME |
| RWA_WEB_RCON | FALSE |
| RWA_RCON_PORT | 25575 |
| RWA_RCON_PASSWORD | empty |
| RWA_WEBSOCKET_URL_SSL | none (wss://) |
| RWA_WEBSOCKET_URL | none (ws://) |

## Ports
- 4326 web UI (README default http://localhost:4326). 4327 websocket (port + 1, per plan.md from config.template.js).

## Volumes/paths and persistent data
- Database hard-coded to `<app>/db` (plan.md from src/db.js), plus `db/server_<id>` folders. Widgets under `public/widgets`. Logs and pid only for startscripts (not used).

## Config files
- Port and allowed hosts in `/config.template.js` (README). Keys not listed on the README.

## Version/release info
- Release 0.14.1: title "Showing Dockerfiles some love", tag 0.14.1, marked Latest, published by lacaulac, 09 Jun (year not shown), commit 4a8b04a (merge of PR #18 "Fix references to archived repository"). Release page reports 2 assets; names did not render. No written release notes.
- Tags have no `v` prefix.
- Archive URL pattern: `https://github.com/rcon-web-admin/rcon-web-admin/archive/<VERSION>.tar.gz` (no v prefix).

## Arch support
- Pure JavaScript; no per-arch artifact.

## Gotchas
- README: "Avoid running as root or with sudo" (upstream guidance for a bare install).
