# modem7/docker-rickroll (Docker Hub)

Source URL(s) + fetch date (2026-11-26):
- https://hub.docker.com/r/modem7/docker-rickroll (fetched)

## What it is
Self-hosted, self-contained Rickroll container. Built on nginxinc/nginx-unprivileged, non-root, video bundled at build time.

## Architectures
- linux/amd64, linux/arm64/v8.

## Tags
- `480p` (854x480), `720p` (1280x720), `latest` / `1080p` (1920x1080, same image), `2160p` (3840x2160). Only the baked-in resolution differs. Latest about 238.7 MB.
- Also published on GHCR as `ghcr.io/modem7/docker-rickroll`.

## Run/compose
- `docker run -d -p 8080:8080 --name rickroll modem7/docker-rickroll`, then http://localhost:8080.
- Compose: service `rickroll`, image `modem7/docker-rickroll`, container_name `Rickroll`, ports `8080:8080`.

## Env vars (page)
- PORT (8080), OVERLAY (both), TITLE (Rickroll), PRE_TITLE (Loading...), HEADLINE (none), HEIGHT (100vh), WIDTH (100%), OBJECT_FIT (cover), LOOP (true), VIDEO_FILE (video.mp4; filename or full URL).

## Volumes
- None needed.

## Build arg
- VIDEO_URL: selects which pre-transcoded release asset is baked in.
