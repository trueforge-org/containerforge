# fireshare

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: fireshare
- **Rows**: 1
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **Source repository**: https://github.com/fireshare-app/fireshare

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: fireshare
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/shaneisrael/fireshare:1.9.3`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/ShaneIsrael/fireshare/blob/6889f4484e3163231ce337ea0aa231b99cbfb5c4/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/fireshare-app/fireshare)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/fireshare-app/fireshare/releases/tag/v1.9.3)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Python Flask app plus React client built by node, running ffmpeg with NVIDIA CUDA/NVENC on nvidia/cuda 11.8. A GPU variant needs device access and a CUDA-capable ffmpeg; reuse python-node and the ffmpeg sibling for a CPU build. Rootless GPU use is the main blocker.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [shaneisrael/fireshare:1.9.3](https://hub.docker.com/r/shaneisrael/fireshare)
- **copy-from arm64**: [shaneisrael/fireshare:1.9.3](https://hub.docker.com/r/shaneisrael/fireshare)

### Dependency containers

- **Dependency containers**: none
