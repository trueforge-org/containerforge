# GitHub: rroller/media-roller Dockerfile @ 968415c

Source URL(s): https://raw.githubusercontent.com/rroller/media-roller/968415c8a43992941c4aaf54eb7d2f97b85120be/Dockerfile (fetched 2026-11-26)

## Stages
- Build: `FROM golang:1.27.4-alpine3.24 AS builder`
  - `apk add curl`; WORKDIR /app; COPY src, templates, go.mod, go.sum
  - `go mod download`; `go build -x -o media-roller ./src`
- Runtime: `FROM python:3.15.2-alpine3.24`
  - `ENV MR_DOWNLOAD_DIR=/download`
  - apk add (no-cache): deno curl gcc musl-dev python3-dev libffi-dev
  - COPY --from=mwader/static-ffmpeg:9.0.2-1 /ffmpeg and /ffprobe to /usr/local/bin/
  - COPY --from=builder /app/media-roller /app/media-roller; COPY templates /app/templates; COPY static /app/static
  - WORKDIR /app
  - `pip install curl_cffi --upgrade --pre`
  - `pip install -U yt-dlp-ejs`
  - yt-dlp: `curl -L https://github.com/yt-dlp/yt-dlp/releases/download/2026.10.26/yt-dlp -o /usr/local/bin/yt-dlp`, sha256 `e51e69e89489f199530f13d32a4342da3ddb2cf34842f364603a066db05afbf3` checked, chmod a+rx
  - `yt-dlp --update --update-to nightly`
  - `yt-dlp --version && ffmpeg -version`
  - `ENTRYPOINT ["/app/media-roller"]`

## Runtime
- No USER instruction: runs as root. No uid/gid set.
- No EXPOSE, VOLUME, CMD, HEALTHCHECK, ARG in this file.
- Port 3000 (from README docker example and bookmarklet).

## Gotchas
- Base is Python alpine; yt-dlp binary is checksum-pinned, so bumping yt-dlp requires updating both the version path and the sha256.
- deno is installed for yt-dlp JS challenges (comment links yt-dlp issue 14404).
