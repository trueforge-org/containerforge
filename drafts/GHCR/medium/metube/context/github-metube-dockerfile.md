# alexta69/metube Dockerfile and docker-entrypoint.sh (master)

Source URL(s) + date:
- https://raw.githubusercontent.com/alexta69/metube/master/Dockerfile (2026-11-27)
- https://raw.githubusercontent.com/alexta69/metube/master/docker-entrypoint.sh (2026-11-27)

## What it is
Two-stage build: Angular UI built on Node, then Python 3.14 runtime with yt-dlp, ffmpeg, aria2, bgutil POT provider.

## Build stages
| stage | base | what |
| --- | --- | --- |
| builder | node:22-alpine@sha256:c610fcdfb1d5b4740dd70c284ed3cb16bb857e0f7166196e36a5501df7a3aa32 | corepack enable; prepare pnpm; COPY ui; `CI=true pnpm install && pnpm run build`; output `/metube/dist/metube` (thrown away except ui dist) |
| final | python:3.14-slim | runtime |

Pin comments in Dockerfile: floating `lts-alpine` lagged; node:22-alpine digest pinned because a 2026-09-17 rebuild failed under QEMU arm64 (`qemu: uncaught target signal 4`).

## Final stage install
- WORKDIR /app; COPY pyproject.toml uv.lock docker-entrypoint.sh
- apt: ca-certificates xz-utils unzip aria2 coreutils gosu curl tini build-essential (build-essential purged after uv sync)
- uv installed to /usr/local/bin via astral install.sh; `UV_PROJECT_ENVIRONMENT=/usr/local uv sync --frozen --no-dev --compile-bytecode`; uv removed afterwards
- `mkdir /.cache && chmod 777 /.cache`
- ffmpeg: static BtbN build, `ARG FFMPEG_BRANCH=8.1`, URL `https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-n${FFMPEG_BRANCH}-latest-${linux64|linuxarm64}-gpl-${FFMPEG_BRANCH}.tar.xz`; extracts ffmpeg and ffprobe to /usr/local/bin. amd64 -> linux64, arm64 -> linuxarm64, others fail.
- bgutil: tag resolved from `github.com/jim60105/bgutil-ytdlp-pot-provider-rs/releases/latest` redirect; binary `bgutil-pot-linux-${x86_64|aarch64}` to /usr/local/bin/bgutil-pot; plugin zip `bgutil-ytdlp-pot-provider-rs.zip` unzipped into python site-packages.
- COPY app ./app; COPY --from=builder /metube/dist/metube ./ui/dist/metube

## Runtime
- ENTRYPOINT `["/usr/bin/tini", "-g", "--", "./docker-entrypoint.sh"]`
- Entrypoint runs `python3 app/main.py` (as PUID:PGID via gosu when started as root; as current uid otherwise). Starts `bgutil-pot server` in background (log /tmp/bgutil-pot.log).
- Root path: chowns /app, DOWNLOAD_DIR, AUDIO_DOWNLOAD_DIR, STATE_DIR, TEMP_DIR to PUID:PGID unless CHOWN_DIRS=false.
- Nightly yt-dlp: only when YTDL_NIGHTLY_UPDATE_TIME set and running as root. Supervisor restarts on exit code 42 (yt-dlp upgrade).
- Entrypoint `PUID="${UID:-$PUID}"`, `PGID="${GID:-$PGID}"`, umask from UMASK.

## Env vars (Dockerfile ENV)
| var | value |
| --- | --- |
| PUID | 1000 |
| PGID | 1000 |
| UMASK | 022 |
| DOWNLOAD_DIR | /downloads |
| STATE_DIR | /downloads/.metube |
| TEMP_DIR | /downloads |
| PORT | 8081 |
| METUBE_VERSION | from ARG VERSION (default dev) |

## Ports
- EXPOSE 8081

## Volumes/paths
- VOLUME /downloads; /.cache (777); /app; /usr/local/bin/bgutil-pot.

## Healthcheck
- `--interval=30s --timeout=5s --start-period=20s --retries=3`; `curl -fsS http://localhost:${PORT}/` (https variant when HTTPS true).

## Version/asset naming
- ffmpeg: `ffmpeg-n8.1-latest-linux64-gpl-8.1.tar.xz` pattern.
- bgutil: `bgutil-pot-linux-x86_64|aarch64`, `bgutil-ytdlp-pot-provider-rs.zip`, tag from latest redirect.

## Arch
- TARGETARCH amd64 and arm64 only.

## Gotchas
- Chart sets STATE_DIR=/config and mounts /config; upstream default is /downloads/.metube.
- Entrypoint is the upstream process supervisor; it must stay as the image ENTRYPOINT under tini.
- Image is built with build-essential purged after uv sync; no compilers remain.
