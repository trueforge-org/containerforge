# Docker Hub: gregyankovoy/chowdown (upstream image)

Source URL(s) + fetch date:
- https://hub.docker.com/r/gregyankovoy/chowdown (fetched 2026-11-26)

## What it is
"A lightweight alpine container for chowdown.io", published by gregyankovoy. About 1M+ pulls, 3 stars.

## Install/run
- `docker pull gregyankovoy/chowdown`
- `docker run --name chowdown -d -p 4000:4000/tcp -v "storage/dir:/config" --restart=unless-stopped gregyankovoy/chowdown:latest`

## Tags and architectures
- Only `latest` is shown. Size about 57.6 MB. Supported architectures are not stated on the page.
- Chart pins `latest@sha256:7941ebe37bab142a05f7b241e2490fa2c60f3644b4327d4dbac82c7b0f73243c` (from TrueCharts values, see truecharts-chowdown.md).

## Ports
- 4000/tcp.

## Volumes/paths and persistent data
- `/config` (host dir mounted).

## Env vars
None documented.

## Version/release info
- Last updated "almost 7 years ago" per the relative timestamp. The image is effectively unmaintained.

## Gotchas
- Image is unmaintained and its Dockerfile is broken as written (see github-gregyankovoy-docker-chowdown.md).
- Port 4000 here, while draft.md says 80/http and plan.md says 8080 for the ContainerForge build.
