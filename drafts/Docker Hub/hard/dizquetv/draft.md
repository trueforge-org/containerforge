# dizquetv

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: dizquetv
- **Rows**: 1
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **Source repository**: https://github.com/vexorian/dizquetv
- **Documentation**: https://github.com/vexorian/dizquetv/wiki

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: dizquetv
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/vexorian/dizquetv:1.7.0, 1.7.0-nvidia`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/vexorian/dizquetv/blob/ce37783/Dockerfile-nvidia)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/vexorian/dizquetv)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/vexorian/dizquetv/releases/download/1.7.0/dizquetv-linux-x64) · [arm64](https://github.com/vexorian/dizquetv/releases/tag/1.7.0)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: The nvidia variant builds on jrottenberg/ffmpeg:4.3-nvidia1804, which is a CUDA base that is amd64 only and needs GPU access. The Node app is packaged with nexe, but the npm package runs as-is on either architecture. The GPU dependency is the effort driver.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [vexorian/dizquetv:1.7.0](https://hub.docker.com/r/vexorian/dizquetv)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
