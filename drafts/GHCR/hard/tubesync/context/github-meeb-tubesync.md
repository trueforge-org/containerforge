# meeb/tubesync: Dockerfile, README, latest release

Source URL(s) + date: https://raw.githubusercontent.com/meeb/tubesync/main/Dockerfile, https://raw.githubusercontent.com/meeb/tubesync/main/README.md, https://github.com/meeb/tubesync/releases/latest (302; api.github.com 403 rate limit) (fetched 2026-11-27)

## What it is
- YouTube PVR with web UI (Django/Python app), s6-overlay init, openresty front.
- Latest release: `v0.19.3` (from releases/latest redirect; plan references v0.19.1).

## Build (multi-stage, debian base)
- Pinned ARGs: `BGUTIL_YTDLP_POT_PROVIDER_VERSION=2.0.2`, `FFMPEG_VERSION=N` (FFMPEG_DATE via build arg, yt-dlp FFmpeg-Builds autobuild), `YTDLP_EJS_VERSION=0.8.0`, `ASFALD_VERSION=0.6.0`, `S6_VERSION=3.2.3.2`, `QJS_VERSION=2025-09-13`, `DEBIAN_VERSION=13-slim`, `ALPINE_VERSION=latest`.
- SHA256 ARGs per arch for asfald, s6 (amd64/arm64/noarch), qjs, ffmpeg.
- Stages: `tubesync-base` (debian, apt snapshot optional via `BASE_DEBIAN_SNAPSHOT_URI`), `asfald`, `tailwindcss`, `ffmpeg` (yt-dlp FFmpeg-Builds), `s6-overlay` (from `ghcr.io/meeb/s6-overlay`), `quickjs`, `tubesync-app`, `openresty` (from `ghcr.io/meeb/openresty-repo`), final `tubesync`.
- Final stage: installs deno, uv, python deps via pipenv/uv, npm ci via deno.
- Creates user `app` (`groupadd app`; `useradd -M -d /app -s /bin/false -g app app`).
- `WORKDIR /app`.

## Runtime
- `ENTRYPOINT ["/init"]` (s6-overlay).
- `HEALTHCHECK --interval=1m --timeout=10s --start-period=3m CMD ["/app/healthcheck.py"]`.
- `EXPOSE 4848`.
- `VOLUME ["/config", "/downloads"]`.

## Env vars (Dockerfile ENV)
| Var | Value |
| --- | --- |
| DENO_DIR | /config/cache/deno |
| PYTHON_BASIC_REPL | 1 |
| PYTHONPATH | /app |
| PYTHONPYCACHEPREFIX | /config/cache/pycache |
| S6_CMD_WAIT_FOR_SERVICES_MAXTIME | 0 |
| SQLITE_TMPDIR | /config/cache |
| XDG_CACHE_HOME | /config/cache |
| XDG_CONFIG_HOME | /config/tubesync |
| XDG_STATE_HOME | /config/state |
| DENO_NO_PROMPT / DENO_NO_UPDATE_CHECK | 1 |

## User/UID (README)
- Upstream README runs with `-e PUID=1000 -e PGID=1000 -e TZ=Europe/London` (TZ defaults to UTC if unset).

## Ports
- 4848 (web UI, README `-p 4848:4848`).

## Volumes/paths
- `/config` (config, cache, state), `/downloads` (media).

## Healthcheck
- `/app/healthcheck.py` every 1m, timeout 10s, start-period 3m.

## Arch
- amd64 and arm64 (README).

## Gotchas
- Upstream uses PUID/PGID; TrueCharts chart does not set them.
- `--stop-timeout 1800` recommended in README.
- Dockerfile `check=error=true` syntax header; patches applied via `fettle.pl` from `patches/`.
