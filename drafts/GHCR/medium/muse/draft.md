# muse

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: medium
- **Chart**: muse
- **Rows**: 1
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **Source repository**: https://github.com/museofficial/muse

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: muse
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/museofficial/muse:2.12.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/museofficial/muse/blob/v2.12.0/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/museofficial/muse)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/museofficial/muse/releases/tag/v2.12.0)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Node.js Discord music bot built with yarn, run from the copied output. Needs yt-dlp via pip and ffmpeg via apt, both available for amd64 and arm64. Several runtime deps and the yt-dlp cache paths put it at medium.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/museofficial/muse:2.12.0](https://ghcr.io/museofficial/muse)
- **copy-from arm64**: [ghcr.io/museofficial/muse:2.12.0](https://ghcr.io/museofficial/muse)

### Dependency containers

- **Dependency containers**: none
