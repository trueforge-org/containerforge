# slskd upstream Dockerfile (commit e472ecd)

## Source URL(s) + date
- https://raw.githubusercontent.com/slskd/slskd/e472ecd/Dockerfile (from blob URL in urls.txt)
- Fetched 2026-11-27

## Stages
- web: `FROM --platform=$BUILDPLATFORM node:22-alpine AS web`; `sh ./bin/build --web-only --version 0.0.1.65534-local`
- publish: `FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:10.0-noble AS publish`; `bash ./bin/build --dotnet-only --version $VERSION`; `bash ./bin/publish --no-prebuild --platform $TARGETPLATFORM --version $VERSION --output ../../dist/${TARGETPLATFORM}`
- final (slskd): `FROM mcr.microsoft.com/dotnet/runtime-deps:10.0-noble AS slskd`
- ARGs: `VERSION=0.0.1.65534-local`, `TAG=0.0.1`, `REVISION=0`, `BUILD_DATE`, `TARGETPLATFORM`

## Final image
- apt installs `jq wget tini gosu` (no-install-recommends), cleanup
- `groupadd -o -g 1000 slskd`; `useradd -o -u 1000 -g slskd slskd`
- `mkdir -p /.net && chmod 777 /.net`
- WORKDIR `/slskd`
- COPY `--from=publish /slskd/dist/${TARGETPLATFORM} .`
- COPY web build → `/slskd/src/slskd/wwwroot/`
- `COPY <<'SCRIPT' /entrypoint.sh` (inline entrypoint; `chmod +x`)
- ENTRYPOINT `["/usr/bin/tini", "--", "/entrypoint.sh"]`; CMD `["./slskd"]`
- HEALTHCHECK `--interval=60s --timeout=3s --start-period=60m --retries=3 CMD wget -q -O - http://localhost:${SLSKD_HTTP_PORT}/health`
- No USER, VOLUME, EXPOSE.

## ENV
- SHELL=/usr/bin/bash; DOTNET_EnableDiagnostics=0; DOTNET_BUNDLE_EXTRACT_BASE_DIR=/.net; DOTNET_gcServer=0; DOTNET_gcConcurrent=1; DOTNET_GCHeapHardLimit=0x80000000; DOTNET_GCConserveMemory=9
- SLSKD_UMASK=0022; SLSKD_HTTP_PORT=5030; SLSKD_HTTPS_PORT=5031; SLSKD_SLSK_LISTEN_PORT=50300
- SLSKD_APP_DIR=/app; SLSKD_DOCKER_TAG/VERSION/REVISION/BUILD_DATE

## Gotchas
- Entrypoint handles `--user`, PUID/PGID (gosu) and root modes (per plan reading; script body not fully shown).
- Upstream image is non-root only if given --user/PUID; chart runs as root.
