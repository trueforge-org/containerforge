# snapshot-controller

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Other registries
- **Difficulty**: medium
- **Chart**: snapshot-controller
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/snapshot-controller
- **Source repository**: https://github.com/kubernetes-csi/external-snapshotter
- **Documentation**: https://kubernetes-csi.github.io/docs/external-snapshotter.html
- **Documentation**: https://kubernetes-csi.github.io/docs/snapshot-controller.html
- **Website**: https://kubernetes-csi.github.io/docs/

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: snapshot-controller
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `registry.k8s.io/sig-storage/snapshot-controller:v8.7.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/kubernetes-csi/external-snapshotter/blob/v8.7.0/cmd/snapshot-controller/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/kubernetes-csi/external-snapshotter)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Go Kubernetes controller; compile cmd/snapshot-controller per arch in a Go build stage and run on the Ubuntu base. Cluster-only, simple build, no runtime state.

### amd64 / arm64

How we get the application for that architecture.

- `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.

- **amd64**: compile
- **arm64**: compile

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

A path in backticks is where the binary sits inside the image.

- **copy-from amd64**: `registry.k8s.io/sig-storage/snapshot-controller:v8.7.0`
- **copy-from arm64**: `registry.k8s.io/sig-storage/snapshot-controller:v8.7.0`

### Dependency containers

- **Dependency containers**: none
