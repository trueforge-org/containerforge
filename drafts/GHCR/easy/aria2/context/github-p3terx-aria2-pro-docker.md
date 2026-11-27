# P3TERX/Aria2-Pro-Docker (upstream image source, commit 4ec58da)
Source URL(s): https://raw.githubusercontent.com/P3TERX/Aria2-Pro-Docker/4ec58da/Dockerfile (fetched), .../4ec58da/rootfs/etc/services.d/aria2/run (fetched, raw alt after API 403), .../4ec58da/README.md (fetched). Repo HTML tree page fetched only as alt, no listing parsed.

## What it is
Aria2 with BitTorrent/Metalink/RPC, packaged on s6 overlay. Supported platforms (README): amd64, i386, arm64, arm/v7, arm/v6.

## Build
- `FROM p3terx/s6-alpine`
- `apk add --no-cache jq findutils`
- `curl -fsSL git.io/aria2c.sh | bash` (runs a REMOTE, unpinned script at build time; installs aria2)
- `rm -rf /var/cache/apk/* /tmp/*`
- `COPY rootfs /`

## Env (Dockerfile ENV defaults)
| Name | Default |
| --- | --- |
| S6_BEHAVIOUR_IF_STAGE2_FAILS | 1 |
| RCLONE_CONFIG | /config/rclone.conf |
| UPDATE_TRACKERS | true |
| CUSTOM_TRACKER_URL | (empty) |
| LISTEN_PORT | 6888 |
| RPC_PORT | 6800 |
| RPC_SECRET | (empty) |
| PUID / PGID | (empty) |
| DISK_CACHE | (empty) |
| IPV6_MODE | (empty) |
| UMASK_SET | (empty; run script uses ${UMASK_SET:-022}) |
| SPECIAL_MODE | (empty) |

## Entrypoint / run
- s6 service run script (rootfs/etc/services.d/aria2/run):
  - `#!/usr/bin/with-contenv bash`, `umask ${UMASK_SET:-022}`
  - `exec s6-setuidgid p3terx aria2c --conf-path=/config/aria2.conf`
- Runs aria2c as user `p3terx` (s6-setuidgid) when the s6 stage runs
- Config file: /config/aria2.conf

## Ports
- EXPOSE 6800 (RPC/HTTP), 6888 (tcp), 6888/udp (DHT/peer)

## Volumes
- /config, /downloads

## User/UID
- Service drops to user `p3terx` via s6-setuidgid; PUID/PGID env in ENV list (handling in init scripts not fetched)

## Healthcheck
- None in Dockerfile

## Config files
- /config/aria2.conf, /config/rclone.conf (RCLONE_CONFIG)

## README (usage, 4ec58da)
- docker run example: `-e PUID -e PGID -e UMASK_SET=022 -e RPC_SECRET -e RPC_PORT=6800 -p 6800:6800 -e LISTEN_PORT=6888 -p 6888:6888 -p 6888:6888/udp -v /config -v /downloads`
- Features: async DNS, BitTorrent, Metalink, XML-RPC, SFTP, auto tracker update, auto cleanup of .aria2 / .torrent files
- WebUI needed separately (e.g. AriaNg)
- Also needs: license MIT (run script header: "free software, licensed under the MIT License")

## Gotchas
- Remote unpinned script `git.io/aria2c.sh` fetched at build time (build reproducibility)
- Chart overrides UPDATE_TRACKERS to false
