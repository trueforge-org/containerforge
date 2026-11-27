# key-networks/ztncui-containerized (upstream README summary)

## Source URL(s) + date
- https://github.com/key-networks/ztncui-containerized (fetched 2026-11-27)
- Duplicate in urls.txt: github.com/kmahyyg/ztncui-aio (api repo 403).

## What it is
- Docker image bundling ZeroTier One and ztncui: standalone ZeroTier network controller with web UI.
- GPLv3. Repo notes the image is now built from key-networks/ztncui-aio; this repo kept as reference docs.
- Published image name: `keynetworks/ztncui` (Docker Hub).

## Run
- `docker run --name ztncui -dp 3443:3443 keynetworks/ztncui`; UI at `https://<host>:3443`.
- Default login admin / password (upstream default).
- Restrict access: `iptables -I INPUT -i eth0+ ! -s $MYADDR -p tcp --dport 3443 -j DROP` via docker exec.

## Volumes
- `/opt/key-networks/ztncui/etc/` (ztncui data).
- `/var/lib/zerotier-one/` (ZeroTier data).

## Env
- `HTTP_PORT`, `HTTP_ALL_INTERFACES=yes` (supported from ztncui 1.2.2). From 1.2.3, `HTTP_ALL_INTERFACES=yes` makes `HTTPS_PORT` ignored; plain HTTP exposed, intended for TLS-offloading proxy only.

## Gotchas
- Upstream default creds are documented; do not ship them as defaults without change (TrueCharts secret default is CHANGEME).
