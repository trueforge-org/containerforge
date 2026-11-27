# ich777/docker-debian-mirror Dockerfile

Source URL: https://raw.githubusercontent.com/ich777/docker-debian-mirror/master/Dockerfile (fetched 2026-11-27, branch master, not a pinned commit)

## What it is
Upstream image `ghcr.io/ich777/debian-mirror`: apt-mirror plus Apache2 serving the mirror, with cron for scheduled sync.

## Base
- `FROM ich777/debian-baseimage` (not fetched; its user/entrypoint conventions are not covered here)
- LABELs: authors admin@minenet.at, source https://github.com/ich777/docker-debian-mirror

## Build steps (single RUN)
- `apt-get update && apt-get -y install apt-mirror xz-utils cron apache2`; `rm -rf /var/lib/apt/lists/*`
- `rm -rf /var/www/*`
- append to `/etc/apache2/apache2.conf`: `ServerName localhost`, `ServerTokens Prod`, `ServerSignature Off`
- sed `/etc/apache2/sites-enabled/000-default.conf`: DocumentRoot -> `/var/www`
- sed `/etc/apt/mirror.list`: `unstable` -> `stable`

## ENV
| Name | Default |
| --- | --- |
| DATA_DIR | /debian-mirror |
| MIRROR_DIR | $DATA_DIR/data |
| CONFIG_DIR | $DATA_DIR/config |
| APACHE2_PORT | 980 |
| CRON_SCHEDULE | 0 1 * * * |
| UID | 99 |
| GID | 100 |
| UMASK | 0000 |
| DATA_PERM | 770 |
| USER | debian |

## User
- RUN: `mkdir -p $DATA_DIR && useradd -d $DATA_DIR -s /bin/bash $USER && chown -R $USER $DATA_DIR && ulimit -n 2048`
- The `ulimit` in a RUN step does not persist to runtime.
- No `USER` directive; runtime user is decided by start.sh (not fetched).

## Scripts
- `ADD /scripts/ /opt/scripts/` and `chmod -R 770 /opt/scripts/`
- `ENTRYPOINT ["/opt/scripts/start.sh"]` (start.sh is in upstream `scripts/` dir, not fetched)

## Ports
- EXPOSE 980 (Apache2)

## Gotchas
- Script-driven: runtime behaviour (UID/GID handling, cron, mirror sync) lives in upstream `scripts/`, which is not in this summary.
- `sources.list` edited to stable via sed on mirror.list, not on sources.list.
