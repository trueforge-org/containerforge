# Reaparr Dockerfile (commit 1e32ea55)

Source: https://github.com/Reaparr/Reaparr/blob/1e32ea55baa826a31cb4ceb3bdfd404bab2f3e11/docker/Dockerfile (raw, pinned commit). Fetched 2026-11-26 (head + tail, same file).

## Stages
| Stage | Base | Work |
| --- | --- | --- |
| client-build | oven/bun:1.4.0-alpine (BUILDPLATFORM) | `COPY ./src/AppHost/ClientApp/`; `bun install --frozen-lockfile`; `bun run generate --fail-on-error` (Nuxt static) |
| back-end | mcr.microsoft.com/dotnet/sdk:10.0 | `dotnet restore src/AppHost/AppHost.csproj --locked-mode`; `dotnet publish AppHost.csproj -c Release -o /app/publish --no-restore` with `ReaparrRuntimeMode=docker`, RID from TARGETPLATFORM |
| dotnet-runtime | mcr.microsoft.com/dotnet/aspnet:10.0-alpine3.22 | runtime copied to /usr/share/dotnet |
| glibc-source | ubuntu:24.04 | donor only: libc.so.6, libm.so.6, ld-linux loader (glibc 2.39 for dash-mpd-cli needing >= 2.38); not in final image |
| gpac-builder | alpine:3.22 | `git clone --depth 1 https://github.com/gpac/gpac.git`; `./configure --static-bin`; `make -j 3`; static MP4Box |
| final | ghcr.io/linuxserver/baseimage-alpine:3.22 (s6-overlay) | apk: bash icu-libs krb5-libs libgcc libintl libssl3 libstdc++ zlib ffmpeg mkvtoolnix |

- Build args: `VERSION=0.0.0`, `INFORMATIONAL_VERSION=0.0.0`, `PORT=7000`, `TARGETPLATFORM` (only linux/amd64 and linux/arm64 accepted), `S6_OVERLAY_VERSION="3.2.1.0"`.
- Copies: `/app/publish` -> `/app`; client `/tmp/ClientApp/.output/public` -> `/app/wwwroot` (chmod u=rwX,go=rX); MP4Box -> /usr/local/bin/MP4Box; `docker/etc/` -> `/etc/`; `docker/10-config` -> `/etc/fix-attrs.d/10-config`.
- Removes `/etc/s6-overlay/s6-rc.d/user/contents.d/svc-cron` (LSIO cron disabled).
- glibc libs bind-mounted from glibc-source in a RUN step; loader to `/lib64/ld-linux-x86-64.so.2` (amd64) or `/lib/ld-linux-aarch64.so.1` (arm64).

## Runtime
- `WORKDIR /app`; `ENTRYPOINT ["/init"]` (s6-overlay).
- Container starts as root; s6 run script drops to user `abc` (`s6-setuidgid abc`).
- `EXPOSE ${PORT}` (7000).
- `VOLUME /Config /Downloads /Movies /TvShows`.

## Env (ENV in final stage)
| Var | Value |
| --- | --- |
| VERSION / INFORMATIONAL_VERSION / PORT | from ARGs |
| DOTNET_ENVIRONMENT | Production |
| DOTNET_URLS | http://+:${PORT} |
| S6_SERVICES_GRACETIME | 15000 |
| REAPARR_PLATFORM | docker |
| UMASK | 002 |
| PATH | + /usr/share/dotnet |

Stage-1 client build env: NUXT_HOST=0.0.0.0, NUXT_PORT, NUXT_PUBLIC_API_PORT, NUXT_PUBLIC_VERSION, NUXT_PUBLIC_PLATFORM=docker (build-time only).

## Gotchas
- gpac is cloned unpinned (default branch, depth 1).
- glibc copied from Ubuntu into Alpine so dash-mpd-cli runs; dotnet itself is musl.
- `UMASK=002` set; app writes to /Config (fix-attrs ensures writable).
- Reaparr crashes if /Config not writable (comment in Dockerfile).
- Syntax directive `docker/dockerfile:1.20`.
