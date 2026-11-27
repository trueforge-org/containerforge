# Upstream docker-compose.yml: debridmediamanager/zurg-public (main)

Source URL(s) + date: https://raw.githubusercontent.com/debridmediamanager/zurg-public/main/docker-compose.yml (fetched 2026-11-27)

## zurg service
- image: `ghcr.io/debridmediamanager/zurg-public:latest`; container_name zurg; restart unless-stopped.
- healthcheck: `curl -f localhost:9999/http/version.txt || exit 1`; interval 10s; timeout 10s; start_period 60s; retries 1000.
- ports: 9999:9999.
- volumes: ./scripts/plex_update.sh -> /app/plex_update.sh; ./config.yml -> /app/config.yml; named volume zurgdata -> /app/data.
- Optional env: TOKEN=YOUR_RD_API_TOKEN_HERE (instead of config.yml mount).

## rclone service (companion)
- image rclone/rclone:latest; env TZ, PUID 1000, PGID 1000.
- volume /mnt/zurg:/data:rshared; ./rclone.conf -> /config/rclone/rclone.conf.
- cap_add SYS_ADMIN; security_opt apparmor:unconfined; device /dev/fuse.
- depends_on zurg service_healthy.
- command: `mount zurg: /data --allow-other --allow-non-empty --dir-cache-time 10s --vfs-cache-mode full`.

## Gotchas
- Healthcheck path /http/version.txt (differs from chart probe, which is tcp).
- Binary in image is /app/zurg; config at /app/config.yml; data at /app/data (matches chart data mount).
