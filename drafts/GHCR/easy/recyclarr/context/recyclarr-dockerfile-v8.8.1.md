# recyclarr Dockerfile (tag v8.8.1)

## Source URL(s) + date
- https://raw.githubusercontent.com/recyclarr/recyclarr/v8.8.1/Dockerfile (fetched 2026-11-27)
- Blob URL `github.com/recyclarr/recyclarr/blob/v8.8.1/Dockerfile` points to the same file (not fetched separately)

## Build
- Stage `build`: `FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:10.0-alpine`; ARG TARGETARCH
- `dotnet restore src/Recyclarr.Cli -a $TARGETARCH`; `dotnet publish src/Recyclarr.Cli -a $TARGETARCH --no-restore -o /app`
- Final: `FROM mcr.microsoft.com/dotnet/runtime:10.0-alpine`
- LABEL: name recyclarr, source https://github.com/recyclarr/recyclarr, url https://recyclarr.dev, licenses MIT
- `apk add --no-cache bash tzdata supercronic git tini`
- `mkdir -p /config /data && chown 1000:1000 /config /data`
- `COPY --link --from=build /app /app/recyclarr/`; `COPY --chmod=555 ./docker/scripts/*.sh /` (entrypoint.sh, cron.sh at /)

## Runtime
- ENV: PATH += /app/recyclarr; RECYCLARR_CONFIG_DIR=/config; CRON_SCHEDULE="@daily"; RECYCLARR_CREATE_CONFIG=false; COMPlus_EnableDiagnostics=0
- `USER 1000:1000`; `VOLUME /config`
- `ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]` (no CMD)

## Env (Dockerfile defaults)
| Name | Default |
| --- | --- |
| RECYCLARR_CONFIG_DIR | /config |
| CRON_SCHEDULE | @daily |
| RECYCLARR_CREATE_CONFIG | false |
| COMPlus_EnableDiagnostics | 0 |

## Ports / Healthcheck
- None

## User/UID
- 1000:1000 (uid/gid set in USER and chown of /config and /data)

## Volumes/paths
- /config (VOLUME), /data (created, chowned, not declared VOLUME)

## Gotchas
- Config file read is `/config/recyclarr.yml` (see entrypoint).
- Requires writable /tmp for `/tmp/crontab` written by entrypoint.
