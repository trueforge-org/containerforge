# obs-ndi

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: obs-ndi
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/obs-ndi
- **Source repository**: https://github.com/DistroAV/DistroAV
- **Documentation**: https://github.com/DistroAV/DistroAV/wiki
- **Website**: https://distroav.org/

## Potentially relevant resources

- **Source code repository**: https://github.com/patrickstigler/docker-obs-ndi
- **Container image**: https://hub.docker.com/r/patrickstigler/obs-ndi

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Desktop streaming app installed from apt and a Linux package on ubuntu, so no language runtime is needed.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: obs-studio (inferred)
- python/pip: none
- node/npm: none
- other: DistroAV x86_64 .deb (amd64 only), NDI runtime from ndi.video

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 3000/http (KasmVNC web GUI, inferred), 3001/https (KasmVNC web GUI TLS, inferred), 5900/tcp (VNC, inferred)

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: obs-ndi
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/patrickstigler/obs-ndi:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/patrickstigler/docker-obs-ndi/blob/400fc92a0a6953feef3bee371f5e0c2cd23991e2/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/DistroAV/DistroAV)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/DistroAV/DistroAV/releases/download/6.2.2/distroav-6.2.2-x86_64-linux-gnu.deb)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: OBS Studio from apt plus the DistroAV x86_64 deb (and the NDI runtime from ndi.video) on containerforge-ubuntu. Desktop GUI needs kasmvnc or xvfb with GL and rootless rework; amd64 only because DistroAV ships no arm64 package.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.
- `no`: neither works for that architecture, for example closed-source software where the vendor only ships an amd64 executable.

- **amd64**: yes
- **arm64**: no

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [patrickstigler/obs-ndi:latest](https://hub.docker.com/r/patrickstigler/obs-ndi)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
