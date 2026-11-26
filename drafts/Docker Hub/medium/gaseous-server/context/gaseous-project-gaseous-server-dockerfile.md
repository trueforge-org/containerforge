# gaseous-project/gaseous-server (build/Dockerfile @ 139459c)

Source URL(s): https://github.com/gaseous-project/gaseous-server/blob/139459c1e4d989772545ca5da8cf36aaee215a3b/build/Dockerfile (raw fetched: https://raw.githubusercontent.com/gaseous-project/gaseous-server/139459c1e4d989772545ca5da8cf36aaee215a3b/build/Dockerfile) ; https://github.com/gaseous-project/gaseous-server
Date: fetched 2026-11-26

## What it is
- ROM/game library manager (metadata via IGDB). .NET 8 web server (gaseous-server.dll) with EmulatorJS web player assets. Needs MariaDB/MySQL, optional IGDB API key, FFmpeg for conversions.

## Build (build/Dockerfile @ 139459c)
- Stage build-env: `FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:8.0`; ARG TARGETARCH, BUILDPLATFORM; WORKDIR `/App`; EXPOSE 80 (in build stage).
  - `dotnet restore gaseous-server/gaseous-server.csproj -a $TARGETARCH`
  - `dotnet publish gaseous-server/gaseous-server.csproj --use-current-runtime --self-contained true -c Release -o out -a $TARGETARCH`
  - apt-get update + upgrade; install `p7zip-full`
  - mkdir `out/wwwroot/emulators/EmulatorJS`; download `https://cdn.emulatorjs.org/releases/4.2.1.7z` (EmulatorJS 4.2.1); `7z x -y` into that dir; apt clean.
  - COPY `.. ./`.
- Stage runtime: `FROM mcr.microsoft.com/dotnet/aspnet:8.0`; ENV `INDOCKER=1`; WORKDIR `/App`; COPY `--from=build-env /App/out .`; apt-get install `curl`, clean.
- HEALTHCHECK interval 30s, timeout 5s, start-period 60s, retries 3: `curl --fail http://localhost:80/api/v1.1/HealthCheck || exit 1`.
- `ENTRYPOINT ["dotnet", "gaseous-server.dll"]`. No USER, VOLUME, CMD in runtime stage. Runs as root.

## Runtime deps
- .NET 8 runtime (aspnet:8.0). MariaDB 11.1.2 preferred (MySQL 8+ supported); FFmpeg (wiki); IGDB API key optional (wiki/Docker Hub description says required for metadata).

## Entrypoint/flags
- `dotnet gaseous-server.dll`.

## Env vars (chart value keys; app-side names not verified from source)
| Var (chart) | Value |
| --- | --- |
| dbhost | secret `<release>-mariadbcreds`, key plainhost |
| dbuser | chart mariadb username `gaseous` |
| dbname | chart mariadb database `gaseous` |
| dbpass | secret `<release>-mariadbcreds`, key mariadb-password |
| dbport | 3306 |
| igdbclientid | chart `gaseous.igdb.id` (empty default) |
| igdbclientsecret | secret `env-secrets`, key igdbclientsecret (from `gaseous.igdb.secret`, empty default) |
| INDOCKER | 1 (Dockerfile) |

## Ports
- Container: 80 (HEALTHCHECK, chart targetPort 80). Chart service port 5198 (http).

## Volumes/paths (chart)
| Path | Use |
| --- | --- |
| `/root/.gaseous-server` | config |
| `/root/.gaseous-server/Logs` | logs |
| `/root/.gaseous-server/Data` | data |

## User/UID
- root (no USER; chart runAsUser 0).

## Healthcheck
- `curl --fail http://localhost:80/api/v1.1/HealthCheck` (every 30s, start 60s).

## Version/asset naming
- GitHub release `v1.7.14` (2025-07-31), no assets; source tarball `archive/refs/tags/v1.7.14.tar.gz`.
- Docker Hub: `v1.7.14` tag (not in first 10 tags shown); newer `v2.0.0-rc.1..rc.5` and nightly tags exist.

## Arch
- Build uses TARGETARCH (amd64/arm64 via `-a`).

## Gotchas
- Dockerfile downloads EmulatorJS 4.2.1.7z at build time from cdn.emulatorjs.org (no checksum in Dockerfile).
- README (master and main branch) not retrievable (404); wiki Home only, sub-pages (Installation, Configuration File, Container Network Requirements) did not load.
