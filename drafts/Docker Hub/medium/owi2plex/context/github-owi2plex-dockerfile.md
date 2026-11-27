# GitHub: alturismo/owi2plex Dockerfile (master) + scripts
Source URL(s): https://raw.githubusercontent.com/alturismo/owi2plex/master/Dockerfile , .../entrypoint.sh , .../cronjob.sh , .../sample_cron.txt (fetched 2026-11-27)

## Build
- FROM alpine:latest; apk update/upgrade; apk add ca-certificates curl
- python3 py3-pip libxml2 libxml2-dev; g++ libxslt-dev python3-dev (build deps kept, not purged)
- pip3 install lxml; pip3 install owi2plex
- tzdata; ENV TZ=Europe/Berlin; link /etc/localtime
- apk add bash busybox-suid su-exec
- COPY owi2plex.py -> /usr/bin/owi2plex.py
- chmod +x entrypoint.sh, cronjob.sh

## Runtime
- VOLUME /config, /owi2plex
- ENTRYPOINT ["./entrypoint.sh"] (run from /, relative path)
- Entrypoint as above; crond -l 2 -f
- Scripts run as root (no USER)

## Gotchas
- Dockerfile uses MAINTAINER (deprecated), unpinned alpine:latest
- Entrypoint copies cronjob.sh and writes /etc/crontabs/root only when /config/cron.txt absent
- Credentials default placeholders in cronjob.sh (password)
