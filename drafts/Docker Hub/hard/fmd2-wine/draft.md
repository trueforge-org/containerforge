# fmd2-wine

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: fmd2-wine
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/fmd2-wine
- **Source repository**: https://github.com/dazedcat19/FMD2

## Potentially relevant resources

- **Source code repository**: https://github.com/Banh-Canh/docker-FMD2
- **Container image**: https://hub.docker.com/r/banhcanh/docker-fmd2

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Windows app run under Wine with Wine installed from apt.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: wine, wine64 (inferred), p7zip-full (inferred, to extract the .7z), winetricks (inferred)
- python/pip: none
- node/npm: none
- other: FMD2 2.0.34.5 Windows 7z release (amd64 only; Wine prefix in /config); linuxserver KasmVNC base

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: fmd2-wine
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/banhcanh/docker-fmd2:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/Banh-Canh/docker-FMD2/blob/master/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/dazedcat19/FMD2)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/dazedcat19/FMD2/releases/download/2.0.34.5/fmd_2.0.34.5_x86_64-win64.7z)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: FMD2 Windows app run under Wine on the linuxserver KasmVNC base, so the image has a desktop, Wine and the app. The Wine prefix must live in /config, and the process stack is heavy. arm64 would need x86 emulation, which is not practical.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.
- `no`: neither works for that architecture, for example closed-source software where the vendor only ships an amd64 executable.

- **amd64**: yes
- **arm64**: no

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [banhcanh/docker-fmd2:latest](https://hub.docker.com/r/banhcanh/docker-fmd2)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
