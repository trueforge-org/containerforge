# orcaslicer

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR (linuxserver)
- **Difficulty**: hard
- **Chart**: orcaslicer
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/orcaslicer
- **Source repository**: https://github.com/SoftFever/OrcaSlicer
- **Documentation**: https://www.orcaslicer.com/wiki
- **Website**: https://www.orcaslicer.com/

## Potentially relevant resources

- **Container image**: https://ghcr.io/linuxserver/orcaslicer

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Desktop AppImage with no scripting runtime, so ubuntu fits.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: libfuse2 (inferred, AppImage) | none
- python/pip: none | none
- node/npm: none | none
- other: amd64 and arm64 Ubuntu 24.04 AppImage download

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 3000/http (desktop web UI, inferred), 3001/https (desktop web UI, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/orcaslicer
- non-root: no - chart runAsUser 0; draft GUI desktop image needs rootless rework
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - not set in values
- other-security: root, so common root caps added
- extra-persistence: none
- confidence: medium

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: orcaslicer
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/linuxserver/orcaslicer:2.5.1`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/linuxserver/docker-orcaslicer/blob/4b114d95b04b/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/SoftFever/OrcaSlicer)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/SoftFever/OrcaSlicer/releases/download/v2.5.1/OrcaSlicer_Linux_AppImage_Ubuntu2404_V2.5.1.AppImage) · [arm64](https://github.com/SoftFever/OrcaSlicer/releases/download/v2.5.1/OrcaSlicer_Linux_AppImage_Ubuntu2404_aarch64_V2.5.1.AppImage)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Desktop 3D slicer GUI run inside a Selkies desktop image. The upstream release ships an Ubuntu 24.04 AppImage for each arch, but a GUI desktop with VNC needs rework to run rootless on a read-only root, so it is hard.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/linuxserver/orcaslicer:2.5.1](https://ghcr.io/linuxserver/orcaslicer)
- **copy-from arm64**: [ghcr.io/linuxserver/orcaslicer:2.5.1](https://ghcr.io/linuxserver/orcaslicer)

### Dependency containers

- **Dependency containers**: none
