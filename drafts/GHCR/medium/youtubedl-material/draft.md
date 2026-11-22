# youtubedl-material

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: medium
- **Chart**: youtubedl-material
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: yes (mongodb)
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/youtubedl-material
- **Source repository**: https://github.com/Tzahi12345/YoutubeDL-Material
- **Documentation**: https://github.com/Tzahi12345/YoutubeDL-Material/wiki

## Potentially relevant resources

- **Container image**: https://ghcr.io/tzahi12345/youtubedl-material

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: `ghcr.io/trueforge-org/python-node`
- **Reason**: Node backend with ffmpeg and python yt-dlp, so both python and node are needed.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: youtubedl-material
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/tzahi12345/youtubedl-material:nightly-2024-10-01`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/Tzahi12345/YoutubeDL-Material/blob/58f4313e500cfcb17aa801934163f474e7be6172/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/Tzahi12345/YoutubeDL-Material)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/Tzahi12345/YoutubeDL-Material/releases/download/v4.3.2/youtubedl-material-v4.3.2.zip)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Node backend with a prebuilt Angular frontend, ffmpeg and python yt-dlp; MongoDB is optional. Port onto the node base using the release zip into /app, with data under /config; old Node 16 pin and pm2 need updating.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/tzahi12345/youtubedl-material:nightly-2024-10-01](https://ghcr.io/tzahi12345/youtubedl-material)
- **copy-from arm64**: [ghcr.io/tzahi12345/youtubedl-material:nightly-2024-10-01](https://ghcr.io/tzahi12345/youtubedl-material)

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

- **Dependency containers**: mongodb ✅
