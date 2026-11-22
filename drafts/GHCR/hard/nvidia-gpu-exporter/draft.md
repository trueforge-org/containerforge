# nvidia-gpu-exporter

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: hard
- **Chart**: nvidia-gpu-exporter
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/nvidia-gpu-exporter
- **Source repository**: https://github.com/utkuozdemir/nvidia_gpu_exporter

## Potentially relevant resources

- **Container image**: https://ghcr.io/utkuozdemir/nvidia_gpu_exporter

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Prebuilt Go exporter installed from a deb.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: none
- other: nvidia-gpu-exporter v1.19.0 .deb release asset; host nvidia-smi driver at runtime

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 9835/http (metrics)

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: nvidia-gpu-exporter
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/utkuozdemir/nvidia_gpu_exporter:1.19.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/utkuozdemir/nvidia_gpu_exporter/blob/a6712afbab9ad620e7cc7897e11cd084147b5e96/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/utkuozdemir/nvidia_gpu_exporter)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/utkuozdemir/nvidia_gpu_exporter/releases/download/v1.19.0/nvidia-gpu-exporter_1.19.0_linux_amd64.deb) · [arm64](https://github.com/utkuozdemir/nvidia_gpu_exporter/releases/download/v1.19.0/nvidia-gpu-exporter_1.19.0_linux_arm64.deb)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Go exporter that shells out to nvidia-smi, so it needs host NVIDIA driver and GPU device access, which conflicts with a plain rootless read-only container. The binary is a simple release tarball but the GPU/hardware dependency makes it hard.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/utkuozdemir/nvidia_gpu_exporter:1.19.0](https://ghcr.io/utkuozdemir/nvidia_gpu_exporter)
- **copy-from arm64**: [ghcr.io/utkuozdemir/nvidia_gpu_exporter:1.19.0](https://ghcr.io/utkuozdemir/nvidia_gpu_exporter)

### Dependency containers

- **Dependency containers**: none
