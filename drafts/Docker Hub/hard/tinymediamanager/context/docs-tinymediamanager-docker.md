# tinyMediaManager Docker docs

**Source URL(s):** https://www.tinymediamanager.org/docs/docker
**Fetched:** 2026-11-26

## Image
- `tinymediamanager/tinymediamanager`, tag `latest` (experimental). Built on Debian Buster, bundles current libmediainfo and FFmpeg.
- Architecture: x86_64 only ("any x86_64 device"). No arm64 tag shown on Docker Hub.
- Size about 658.3 MB; 5M+ pulls.
- Remote access: noVNC web (port 4000) or VNC (5900).

## Ports
- `4000`: web interface (noVNC), access at `http://<host>:4000`.
- `5900`: VNC, used when direct VNC is enabled (`ALLOW_DIRECT_VNC=true`).
- HTTP API (v4.3+): needs a port mapping; the number is not given.

## Env vars
| Variable | Purpose | Default |
| --- | --- | --- |
| USER_ID | UID tmm runs as | 1000 |
| GROUP_ID | GID tmm runs as | 1000 |
| PASSWORD | remote access password | none |
| LC_TIME | `en_US.UTF-8` = 12h, `C.UTF-8` = 24h | none |
| TZ | timezone | none |
| ALLOW_DIRECT_VNC | direct VNC access | false |

Compose/run examples also set `LC_ALL=en_US.UTF-8` and `LANG=en_US.UTF-8` (no default in the table).

## Volumes
- `/data`: all tmm data (data, logs, cache, backups). Unmapped data is lost on upgrade.
- `/media/xxx`: media sources, e.g. `/media/movies`, `/media/tvshows`. Read/write needed.
- `/app/addons`: custom scrapers (the overview also mentions `/data/addons`).
- `/app/launcher-extra.yml`: custom start parameters.

## launcher-extra.yml (in the image)
```
---
javaHome: ""
jvmOpts:
  - "-Dtmm.contentfolder=/data"
  - "-Dtmm.noupdate=true"
env: [ ]
```

## Permissions
Set `USER_ID`/`GROUP_ID` to the host user that owns the data volume (`id <username>` on host).

## Run example
`docker run --name=tinymediamanager -p 4000:4000 -p 5900:5900 -e LC_ALL=en_US.UTF-8 -e LANG=en_US.UTF-8 -e ALLOW_DIRECT_VNC=true -v <data>:/data -v <movies>:/media/movies -v <tvshows>:/media/tvshows -v <addons>:/app/addons tinymediamanager/tinymediamanager:latest` (with json-file log options max-size 20m, max-file 5).

Compose: `USER_ID=1000`, `GROUP_ID=100`, `ALLOW_DIRECT_VNC=true`, `PASSWORD=<password>`, ports 4000 and 5900, `restart: unless-stopped`. One compose volume maps the addons path to `/media/tv_shows`, which looks inconsistent with the `/app/addons` guidance above.

## Clipboard
Browser restrictions block clipboard sync; use the noVNC clipboard panel.
