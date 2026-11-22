# csi-addons-controller

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Quay
- **Difficulty**: medium
- **Chart**: csi-addons-controller
- **Rows**: 1
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **Source repository**: https://github.com/csi-addons/kubernetes-csi-addons
- **Website**: https://csi-addons.github.io/

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: csi-addons-controller
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `quay.io/csiaddons/k8s-controller:v0.15.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/csi-addons/kubernetes-csi-addons/blob/c92032331fe7fb165dd1a40dfb7ebb6c83a3b5cb/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/csi-addons/kubernetes-csi-addons)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Go Kubernetes controller built from source and run on distroless nonroot, so it is rootless and cluster-only. Compile it per arch with a Go build stage on the Ubuntu base; modest single-binary build.

### amd64 / arm64

How we get the application for that architecture.

- `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.

- **amd64**: compile
- **arm64**: compile

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [quay.io/csiaddons/k8s-controller:v0.15.0](https://quay.io/repository/csiaddons/k8s-controller)
- **copy-from arm64**: [quay.io/csiaddons/k8s-controller:v0.15.0](https://quay.io/repository/csiaddons/k8s-controller)

### Dependency containers

- **Dependency containers**: none
