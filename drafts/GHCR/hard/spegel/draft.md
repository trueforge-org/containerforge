# spegel

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: hard
- **Chart**: spegel
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/spegel
- **Source repository**: https://github.com/spegel-org/spegel

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: spegel
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/spegel-org/spegel:v0.8.1`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/spegel-org/spegel/blob/7e2e042/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/spegel-org/spegel)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/spegel-org/spegel/releases/download/v0.8.1/spegel_0.8.1_linux_amd64.tar.gz) · [arm64](https://github.com/spegel-org/spegel/releases/download/v0.8.1/spegel_0.8.1_linux_arm64.tar.gz)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Spegel is a Go binary with prebuilt linux tarballs, so the binary itself is easy. It is a node-level DaemonSet that writes containerd registry config through hostPath and needs the containerd socket. The host access makes this a hard fit for a rootless, read-only image.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/spegel-org/spegel:v0.8.1](https://ghcr.io/spegel-org/spegel)
- **copy-from arm64**: [ghcr.io/spegel-org/spegel:v0.8.1](https://ghcr.io/spegel-org/spegel)

### Dependency containers

- **Dependency containers**: none
