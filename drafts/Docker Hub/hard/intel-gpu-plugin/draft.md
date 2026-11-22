# intel-gpu-plugin

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: intel-gpu-plugin
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/intel-gpu-plugin
- **Source repository**: https://github.com/intel/intel-device-plugins-for-kubernetes
- **Documentation**: https://intel.github.io/intel-device-plugins-for-kubernetes/0.36/

## Potentially relevant resources

- **Source code repository**: https://github.com/intel
- **Container image**: https://hub.docker.com/r/intel/intel-gpu-plugin

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Go device plugin binary with no language base needed beyond Go build output.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: intel-gpu-plugin
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/intel/intel-gpu-plugin:0.37.1`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/intel/intel-device-plugins-for-kubernetes/blob/v0.37.1/build/docker/intel-gpu-plugin.Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/intel/intel-device-plugins-for-kubernetes)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Go device plugin built from source in a golang stage and copied onto ubi9-micro, so ContainerForge would need its own Go build stage. It needs host /dev/dri GPU device access and a hostPath mount, which is hardware-bound and not a normal rootless service.

### amd64 / arm64

How we get the application for that architecture.

- `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.

- **amd64**: compile
- **arm64**: compile

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [intel/intel-gpu-plugin:0.37.1](https://hub.docker.com/r/intel/intel-gpu-plugin)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
