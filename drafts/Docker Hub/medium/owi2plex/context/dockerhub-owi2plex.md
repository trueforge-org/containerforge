# Docker Hub: alturismo/owi2plex
Source URL(s): https://hub.docker.com/v2/repositories/alturismo/owi2plex/ , .../tags?page_size=10 (fetched 2026-11-27)

## What it is
- Description: "owi2plex"; image is owi2plex in docker with cron (alturismo)
- Pulls 357,284; stars 0; status active; last_updated 2019-11-29
- Tags: only `latest` (count 1), amd64 only in tag data

## Install/build (alturismo Dockerfile, see github-owi2plex-dockerfile.md)
- FROM alpine:latest; apk ca-certificates curl bash busybox-suid su-exec tzdata
- python3 py3-pip libxml2 libxml2-dev g++ libxslt-dev python3-dev; pip3 install lxml; pip3 install owi2plex
- COPY ./owi2plex.py /usr/bin/owi2plex.py (fix file in repo)
- ADD cronjob.sh, entrypoint.sh, sample_cron.txt to /

## Runtime deps
Python 3 + owi2plex (pip) + lxml; crond (busybox); bash; tzdata

## Entrypoint/CMD
- ENTRYPOINT ["./entrypoint.sh"]
- No CMD. Entry runs `crond -l 2 -f` (foreground cron)

## Env vars
| Var | Value |
| --- | --- |
| TZ | Europe/Berlin (ENV default; /etc/localtime linked) |

## Ports
- None exposed (no EXPOSE)

## Volumes/paths
- VOLUME /config, VOLUME /owi2plex
- /TVH used by cronjob.sh only when TVH move enabled (chart mounts /TVH)

## Entrypoint behaviour (entrypoint.sh)
- If /config/cronjob.sh missing: copy /cronjob.sh there, chmod 777
- If /config/cron.txt exists: source it (crontab content); else write `0 0 * * * /config/cronjob.sh` to /etc/crontabs/root and copy /sample_cron.txt to /config/sample_cron.txt
- Then `crond -l 2 -f`

## cronjob.sh (config block, defaults from image)
- use_owi2plex="yes"; bouquets="UHD SPORT"
- owi_ip, owi_user, owi_pass (defaults 192.168.1.103 / root / password)
- For each bouquet: owi2plex -h $owi_ip -u $owi_user -p $owi_pass -b $bouquet -o /owi2plex/enigma$bouquet.xml
- Optional: use_TVH_Play (wget playlist), use_xTeveAPI (POST update.xmltv/xepg to xTeve), use_TVH_move (cp to $TVHPATH/guide.xml), all "no" by default
- Config is edited in /config/cronjob.sh (persistent)

## Version/asset naming
- No versions: tag `latest` only. Upstream pip package: owi2plex (PyPI), latest at build time

## Arch
- amd64 only in tag data

## Gotchas
- Image last rebuilt 2019; upstream Dockerfile uses alpine:latest and unpinned pip installs
- Running as root (chart). Scripts are not gated by a user
- Cron schedule changes apply on container restart (readme)
- Setup persists in /config; delete to reset
