# openaudible

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: openaudible
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/openaudible
- **Website**: https://openaudible.org/
- **Documentation**: https://openaudible.org/documentation

## Potentially relevant resources

- **Source code repository**: https://github.com/openaudible/openaudible_docker
- **Container image**: https://hub.docker.com/r/openaudible/openaudible

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Closed-source desktop app with a Linux package, run over a GUI base on ubuntu.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: none
- other: OpenAudible .deb (vendor, amd64 only), GUI base (kasmvnc)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 3000/http (KasmVNC web GUI, inferred), 3001/https (KasmVNC web GUI TLS, inferred)

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: openaudible
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/openaudible/openaudible:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/openaudible/openaudible_docker/blob/master/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://openaudible.org/)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://openaudible.org/latest/OpenAudible_x86_64.deb)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Closed-source desktop app for Mac, Windows and Linux, run as a wrapper over the linuxserver kasmvnc base. It has a vendor Linux download but no redistributable container build, and a GUI with startup scripts that must be rebuilt to run rootless.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.
- `no`: neither works for that architecture, for example closed-source software where the vendor only ships an amd64 executable.

- **amd64**: yes
- **arm64**: no

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [openaudible/openaudible:latest](https://hub.docker.com/r/openaudible/openaudible)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
