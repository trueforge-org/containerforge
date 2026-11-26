# iPromKnight/zilean: Dockerfile and requirements.txt

## Source URL(s) + date
- https://raw.githubusercontent.com/iPromKnight/zilean/ee5cbb7e41de282d8dd87f5a27e667a74370b196/Dockerfile (fetched 2026-11-26)
- https://raw.githubusercontent.com/iPromKnight/zilean/HEAD/requirements.txt (fetched 2026-11-26)

## What it is
- Zilean: .NET 9 search service (ApiService + Scraper) for DebridMediaManager content, exposed as Torznab indexer. Python helper deps for torrent name parsing.

## Install/build steps (Dockerfile, 2 stages)
- Build: `FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:9.0-alpine AS base`, `ARG TARGETARCH`, `WORKDIR /build`, `COPY . .`
  - `dotnet restore -a $TARGETARCH`
  - `cd src/Zilean.ApiService && dotnet publish -c Release --no-restore -a $TARGETARCH -o /app/out`
  - `cd src/Zilean.Scraper && dotnet publish -c Release --no-restore -a $TARGETARCH -o /app/out`
- Run: `FROM mcr.microsoft.com/dotnet/aspnet:9.0-alpine`
  - Replace apk repos with alpine v3.18 main + community; `apk update`
  - `apk add --update --no-cache python3=~3.11 py3-pip=~23.1 curl icu-libs && ln -sf python3 /usr/bin/python`
  - `WORKDIR /app`, `VOLUME /app/data`
  - `COPY --from=base /app/out .` and `COPY --from=base /build/requirements.txt .`
  - `rm -rf /app/python; mkdir -p /app/python`
  - `pip3 install -r /app/requirements.txt -t /app/python`
  - `ENTRYPOINT ["./zilean-api"]` (no CMD)

## requirements.txt
```
loguru==0.7.2
rich==13.8.0
rank-torrent-name==1.5.3
```

## Runtime deps
- .NET 9 aspnet runtime (alpine image), Python 3.11 (alpine 3.18 pin), py3-pip 23.1, curl, icu-libs.

## Entrypoint/flags
- `./zilean-api` (no args).

## Env vars (Dockerfile)
| Var | Value |
| --- | --- |
| DOTNET_RUNNING_IN_CONTAINER | true |
| DOTNET_SYSTEM_GLOBALIZATION_INVARIANT | false |
| PYTHONUNBUFFERED | 1 |
| ZILEAN_PYTHON_PYLIB | /usr/lib/libpython3.11.so.1.0 |
| ASPNETCORE_URLS | http://+:8181 |

## Ports
- 8181 (ASPNETCORE_URLS). No EXPOSE.

## Volumes/paths
- `VOLUME /app/data`. Build outputs in `/app`; python libs in `/app/python`.

## User/UID
- Not set (root by default).

## Healthcheck
- None in Dockerfile.

## Version/asset naming
- Not in these files. Upstream tags use `vX.Y.Z` (per plan.md; not verified here).

## Arch
- Build stage uses `TARGETARCH` for `dotnet -a`. Multi-arch via `$BUILDPLATFORM`.

## Gotchas
- Alpine 3.18 repos and dotnet 9.0 images are pinned by the upstream Dockerfile (old base).
- `pip3 install` runs at image build; requires network at build time only.
