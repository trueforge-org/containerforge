# grafana-image-renderer

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: grafana-image-renderer
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/grafana-image-renderer
- **Source repository**: https://github.com/grafana/grafana-image-renderer

## Potentially relevant resources

- **Source code repository**: https://github.com/grafana/grafana-image-renderer/blob/master/docs/remote_rendering_using_docker.md
- **Container image**: https://hub.docker.com/r/grafana/grafana-image-renderer

## Base container

- **Foundation**: ubuntu (`ghcr.io/trueforge-org/ubuntu:26.4`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Go renderer driving a headless browser installed from apt.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: grafana-image-renderer
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/grafana/grafana-image-renderer:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/grafana/grafana-image-renderer/blob/76ca73f6e1f00b46ee91524bbd91718545ea5943/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/grafana/grafana-image-renderer)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/grafana/grafana-image-renderer/releases/download/v5.12.11/grafana-image-renderer-linux-amd64) · [arm64](https://github.com/grafana/grafana-image-renderer/releases/download/v5.12.11/grafana-image-renderer-linux-arm64)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Go renderer that drives a headless Chromium installed by apt on debian. Ubuntu's chromium is a snap, so a working browser needs a different source, and sandbox flags and rootless operation add work. Read-only rootfs needs a /tmp profile.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [grafana/grafana-image-renderer:latest](https://hub.docker.com/r/grafana/grafana-image-renderer)
- **copy-from arm64**: [grafana/grafana-image-renderer:latest](https://hub.docker.com/r/grafana/grafana-image-renderer)

### Dependency containers

- **Dependency containers**: none
