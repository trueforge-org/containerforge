# nullserv

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: medium
- **Chart**: nullserv
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/nullserv
- **Source repository**: https://github.com/bmrzycki/nullserv

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: nullserv
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/k8s-at-home/nullserv:v1.3.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/bmrzycki/nullserv/blob/master/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/bmrzycki/nullserv)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Small static Go null server built in a builder stage and copied onto scratch, per the upstream master Dockerfile. The mapping is unconfirmed since the k8s-at-home repo is gone and v1.3.0 was not checked. Needs a go builder stage and a high port rootless. Medium.

### amd64 / arm64

How we get the application for that architecture.

- `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.

- **amd64**: compile
- **arm64**: compile

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/k8s-at-home/nullserv:v1.3.0](https://ghcr.io/k8s-at-home/nullserv)
- **copy-from arm64**: [ghcr.io/k8s-at-home/nullserv:v1.3.0](https://ghcr.io/k8s-at-home/nullserv)

### Dependency containers

- **Dependency containers**: none
