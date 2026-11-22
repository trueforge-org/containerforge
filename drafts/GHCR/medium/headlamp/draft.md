# headlamp

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: medium
- **Chart**: headlamp
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/headlamp
- **Source repository**: https://github.com/headlamp-k8s/headlamp

## Potentially relevant resources

- **Container image**: https://ghcr.io/headlamp-k8s/headlamp
- **Source code repository**: https://github.com/kubernetes-sigs/headlamp
- **Source code repository**: https://github.com/trueforge-org/containers/tree/main/apps/node
- **Website**: https://headlamp.dev

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: headlamp
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/headlamp-k8s/headlamp:v0.46.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/headlamp-k8s/headlamp/blob/v0.46.0/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/headlamp-k8s/headlamp)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/headlamp-k8s/headlamp/releases/download/v0.46.0/Headlamp-0.46.0-linux-x64.tar.gz) · [arm64](https://github.com/headlamp-k8s/headlamp/releases/download/v0.46.0/Headlamp-0.46.0-linux-arm64.tar.gz)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Extract resources/headlamp-server and resources/frontend from the per-arch Electron tarball into /app on containerforge-ubuntu, ignoring the desktop shell. Run as user apps with no state beyond kubeconfig and plugins under /config.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: no
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
