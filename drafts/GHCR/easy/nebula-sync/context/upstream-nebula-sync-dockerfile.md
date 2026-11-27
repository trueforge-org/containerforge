# nebula-sync upstream Dockerfile, release and license

Source URL(s) + date: https://raw.githubusercontent.com/lovelaze/nebula-sync/v0.11.3/Dockerfile ; https://api.github.com/repos/lovelaze/nebula-sync/releases/tags/v0.11.3 ; https://raw.githubusercontent.com/lovelaze/nebula-sync/main/LICENSE (fetched 2026-11-27)
License: MIT

## Build stages
| Stage | Base | Notes |
| --- | --- | --- |
| 1 (alias golang) | golang:1.26-alpine | WORKDIR /app; `apk add tzdata ca-certificates`; `COPY . .`; `go mod download`; `go mod verify`; `go build .` |
| 2 | scratch | copies zoneinfo, CA bundle, binary |

- Build ARG: VERSION=dev, used in ldflags `-X=github.com/lovelaze/nebula-sync/version.Version=${VERSION}`.
- Build env: GO111MODULE=on, CGO_ENABLED=0, GOOS=linux; GOFLAGS `-a -trimpath -ldflags=-w -ldflags=-s ...`.
- Output binary: /app/nebula-sync, copied to /usr/local/bin/nebula-sync.

## Final image (scratch)
- COPY --link /usr/share/zoneinfo/ ; /etc/ssl/certs/ca-certificates.crt ; /usr/local/bin/nebula-sync
- USER 1001 (no GID)
- ENV API_ENABLED=true
- ENTRYPOINT ["nebula-sync"]; CMD ["run"]
- HEALTHCHECK interval 30s, timeout 3s, start-period 3s, retries 3; CMD `["nebula-sync", "healthcheck"]`
- No EXPOSE, no VOLUME, no WORKDIR in final stage.

## Runtime / config (from README)
- Syncs Pi-hole v6.x only (community project, not official Pi-hole).
- Modes: full sync (Teleporter, FULL_SYNC=true), selective sync (FULL_SYNC=false), cron (CRON).
- Required: PRIMARY (`url|password`), REPLICAS (comma-separated `url|password`). File variants: PRIMARY_FILE / REPLICAS_FILE (Docker secrets, e.g. /run/secrets/...).
- Optional: RUN_GRAVITY (false), TZ, CLIENT_SKIP_TLS_VERIFICATION (false), CLIENT_RETRY_DELAY_SECONDS (1), CLIENT_TIMEOUT_SECONDS (20).
- Selective sync (only if FULL_SYNC=false; all default false): SYNC_CONFIG_{DNS,DHCP,NTP,RESOLVER,DATABASE,MISC,DEBUG}, SYNC_GRAVITY_{DHCP_LEASES,GROUP,AD_LIST,AD_LIST_BY_GROUP,DOMAIN_LIST,DOMAIN_LIST_BY_GROUP,CLIENT,CLIENT_BY_GROUP}.
- Config include/exclude filters: SYNC_CONFIG_<SECTION>_INCLUDE / _EXCLUDE (mutually exclusive per section, comma-separated keys).
- Webhooks: WEBHOOK_SYNC_{SUCCESS,FAILURE}_URL (required to trigger), _METHOD (POST), _BODY, _HEADERS (`key:value,...`); WEBHOOK_CLIENT_SKIP_TLS_VERIFICATION (false); timeout 10s.
- Binary CLI: `nebula-sync run`; `nebula-sync run --env-file .env`.

## Ports / volumes
- No ports documented; no volumes documented.

## User/UID
- Runs as UID 1001 (no GID). Docker secrets permission error: fix with chown 1001 + chmod 400 on secret files, or match compose `user:`.

## Version / asset naming (GitHub release)
- Latest tag v0.11.3 (published 2026-10-20). Tag has no leading-v in asset names.
- Assets (11): checksums.txt; nebula-sync_0.11.3_{darwin_amd64,darwin_arm64,linux_386,linux_amd64,linux_arm64,linux_armv6,linux_armv7}.tar.gz; nebula-sync_0.11.3_{windows_386,windows_amd64,windows_arm64}.zip.

## Arch
- Linux: 386, amd64, arm64, armv6, armv7. Darwin amd64/arm64. Windows 386/amd64/arm64.

## Gotchas
- README says no healthcheck is documented, but Dockerfile defines HEALTHCHECK (`nebula-sync healthcheck`); Dockerfile is authoritative.
- Replicas need `webserver.api.app_sudo` enabled for app-password auth (README).
- Chart and README differ on nothing else; upstream image uses scratch, so no shell in container.
