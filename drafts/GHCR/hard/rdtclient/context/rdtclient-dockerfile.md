# rogerfar/rdt-client Dockerfile (commit a669bd3)

**Source URL(s):** https://raw.githubusercontent.com/rogerfar/rdt-client/a669bd3/Dockerfile (blob URL duplicate) · fetched 2026-11-27

## Build stages
1. `node-build-env`: `FROM node:lts-alpine`. Copies `client` and `root`; `cd client && npm install && npx ng build --output-path=out` (Angular frontend).
2. `dotnet-build-env`: `FROM mcr.microsoft.com/dotnet/sdk:10.0-alpine`. Copies `server`; `dotnet restore --no-cache RdtClient.sln && dotnet test && dotnet publish --no-restore -c Release -o out`.
3. Runtime: `FROM ghcr.io/linuxserver/baseimage-alpine:3.20` (linuxserver base, s6 init, uses `abc` user).

## Runtime
- apk: bash, icu-libs, krb5-libs, libgcc, libintl, libssl3, libstdc++, zlib.
- .NET ASP.NET runtime 10.0.0 musl tarball (arm, arm64, x64) extracted to /usr/share/dotnet; PATH includes /usr/share/dotnet.
- `mkdir -p /data/downloads /data/db`; `chown -R abc:abc /data`.
- ENV `XDG_CONFIG_HOME=/config/xdg`, `RDTCLIENT_BRANCH=main`.
- WORKDIR /app; COPY backend `out` to /app, frontend `out/browser` to /app/wwwroot, root files from client build to /.
- `EXPOSE 6500`.
- HEALTHCHECK: `curl --fail http://localhost:6500 || exit` (interval 30s, timeout 30s, start 30s, retries 3).
- No ENTRYPOINT/CMD here (linuxserver base /init).

## Build args / labels
- ARG VERSION, BUILD_DATE; label maintainer `ravensorb`.

## Gotchas
- Runtime is linuxserver baseimage (root init, `abc` user). Not compatible with `USER apps` as-is.
- Build runs `dotnet test`.
- Backend and frontend built from source in the Dockerfile; no separate download of rdtclient release assets.
