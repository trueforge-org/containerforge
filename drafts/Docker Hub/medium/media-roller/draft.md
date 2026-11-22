# media-roller

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: media-roller
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/media-roller
- **Source repository**: https://github.com/rroller/media-roller

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/ronnieroller/media-roller

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Alternative runtime image**: [python](https://github.com/trueforge-org/containerforge/tree/main/apps/python) (`ghcr.io/trueforge-org/python`)
- **Reason**: Go service built in a Go stage with yt-dlp from release; python is the alternative if the Python tooling must run from the base.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: ffmpeg (static build in upstream; apt ffmpeg from ffmpeg sibling)
- python/pip: yt-dlp (release)
- node/npm: none
- other: Go toolchain (go build from source); deno (binary download, for yt-dlp JS)

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: media-roller
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/ronnieroller/media-roller:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/rroller/media-roller/blob/968415c8a43992941c4aaf54eb7d2f97b85120be/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/rroller/media-roller)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Go service compiled from source (go build) plus yt-dlp, deno and static ffmpeg on an alpine Python image. On containerforge-ubuntu build with a Go stage, install yt-dlp from release, ffmpeg from the ffmpeg sibling and python from the python base; downloads go to /tmp.

### amd64 / arm64

How we get the application for that architecture.

- `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.

- **amd64**: compile
- **arm64**: compile

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: no
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
