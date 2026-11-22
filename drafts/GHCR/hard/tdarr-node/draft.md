# tdarr-node

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: hard
- **Chart**: tdarr-node
- **Rows**: 1
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: tdarr-node
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/haveagitgat/tdarr_node:3.08.00`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/HaveAGitGat/Tdarr/blob/9ec31178f6807861c207f8a65a1b8156e46c5b85/docker/Dockerfile.final)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/HaveAGitGat/Tdarr)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://tdarr.io/downloads)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: A single Tdarr worker process, but it still runs as root with bundled Node, ffmpeg and HandBrake tools and needs large transcode cache paths. The rootless and read-only-rootfs rework of the work directories, plus the accelerated base variants, puts it in the hard band.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/haveagitgat/tdarr_node:3.08.00](https://ghcr.io/haveagitgat/tdarr_node)
- **copy-from arm64**: [ghcr.io/haveagitgat/tdarr_node:3.08.00](https://ghcr.io/haveagitgat/tdarr_node)

### Dependency containers

- **Dependency containers**: none
