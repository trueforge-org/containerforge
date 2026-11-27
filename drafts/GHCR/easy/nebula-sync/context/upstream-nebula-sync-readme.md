# nebula-sync upstream README (main)

Source URL(s) + date: https://raw.githubusercontent.com/lovelaze/nebula-sync/main/README.md (fetched 2026-11-27)

## Summary
- Community Go tool syncing Pi-hole v6.x primary to replicas (not official Pi-hole). Image: ghcr.io/lovelaze/nebula-sync:latest.
- Modes: full sync (Teleporter), selective sync, cron-scheduled.
- Supported: Pi-hole v6.x only.

## Run
- Docker Compose: image ghcr.io/lovelaze/nebula-sync:latest; env PRIMARY=`http://ph1.example.com|password`, REPLICAS=`...|password,...`, FULL_SYNC=true, RUN_GRAVITY=true, CRON=`0 * * * *`.
- `docker run --rm -e PRIMARY=... -e REPLICAS=... -e FULL_SYNC=true -e RUN_GRAVITY=true ghcr.io/lovelaze/nebula-sync:latest`
- Binary: `nebula-sync run`, `nebula-sync run --env-file .env`. Go install: `go install github.com/lovelaze/nebula-sync@latest`.

## Ports / volumes
- None documented. Docker secrets optional at /run/secrets/...

## Webhook examples
- healthchecks.io: success `https://hc-ping.com/{slug}`, failure `.../fail`.
- JSON: BODY `{"hello":"world"}`, HEADERS `Content-Type:application/json`.

## Known issues
- `permission denied` on /run/secrets/primary: chown 1001, chmod 400 on secret files, or set compose user to match.
- Replicas: enable webserver.api.app_sudo (`sudo pihole-FTL --config webserver.api.app_sudo true`) to avoid app-password auth errors.

## Gotchas
- README documents no healthcheck; Dockerfile does define one (see upstream-nebula-sync-dockerfile.md).
