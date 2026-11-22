# photoview

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: photoview
- **Rows**: 1
- **Hard dependency containers**: yes (postgresql)
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/photoview
- **Source repository**: https://github.com/photoview/photoview
- **Documentation**: https://photoview.github.io/
- **Website**: https://photoview.github.io/

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: photoview
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/viktorstrate/photoview:2.4.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/photoview/photoview/blob/f79d379e38241c687c55e9f899e30661fd9f115a/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/photoview/photoview)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Go API with cgo-linked image libraries (libheif, dlib, ffmpeg, darktable) plus a node-built React UI, no release artifacts. Two build stages with heavy native deps must be built from source on containerforge-ubuntu, and it needs a database.

### amd64 / arm64

How we get the application for that architecture.

- `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.

- **amd64**: compile
- **arm64**: compile

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [viktorstrate/photoview:2.4.0](https://hub.docker.com/r/viktorstrate/photoview)
- **copy-from arm64**: [viktorstrate/photoview:2.4.0](https://hub.docker.com/r/viktorstrate/photoview)

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

- **Dependency containers**: postgresql ✅
