# raspberrymatic

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: hard
- **Chart**: raspberrymatic
- **Rows**: 1
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **Source repository**: https://github.com/jens-maus/RaspberryMatic

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: raspberrymatic
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/jens-maus/raspberrymatic:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/jens-maus/RaspberryMatic/blob/2b1ef2dad9867a1073b2423c511bcb09c0ca415d/buildroot-external/board/oci/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/jens-maus/RaspberryMatic)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/OpenCCU/OpenCCU/releases/download/3.89.11.20260919/OpenCCU-3.89.11.20260919-generic-x86_64.zip) · [arm64](https://github.com/OpenCCU/OpenCCU/releases/download/3.89.11.20260919/OpenCCU-3.89.11.20260919-generic-aarch64.zip)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: HomeMatic CCU firmware built with buildroot (now OpenCCU) with its own init, several daemons and drivers for HomeMatic radio and USB hardware. It is a whole OS rootfs, needs root and devices, and cannot be rebuilt on containerforge-ubuntu without large rework.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/jens-maus/raspberrymatic:latest](https://ghcr.io/jens-maus/raspberrymatic)
- **copy-from arm64**: [ghcr.io/jens-maus/raspberrymatic:latest](https://ghcr.io/jens-maus/raspberrymatic)

### Dependency containers

- **Dependency containers**: none
