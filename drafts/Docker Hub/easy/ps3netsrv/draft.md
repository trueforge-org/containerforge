# ps3netsrv

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: easy
- **Chart**: ps3netsrv
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/ps3netsrv
- **Source repository**: https://github.com/aldostools/ps3netsrv

## Potentially relevant resources

- **Source code repository**: https://github.com/aldostools/webMAN-MOD/tree/master/_Projects_/ps3netsrv
- **Container image**: https://hub.docker.com/r/shawly/ps3netsrv

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Prebuilt release binary on amd64 and a small C build on arm64, with no interpreter needed.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: unzip (inferred), gcc, meson, ninja-build (inferred)
- python/pip: none
- node/npm: none
- other: amd64 release zip; arm64 C source build

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 38008/tcp (PS3 game-folder network share)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/ps3netsrv
- non-root: possible - chart sets runAsUser 0 and runAsGroup 0; draft has no root step
- read-only-rootfs: possible - chart sets readOnlyRootFilesystem false; draft needs only /tmp writable
- privileged: no - not set, common default false
- other-security: none (port 38008 only)
- extra-persistence: /games (pvc, chart's own mount; draft mounts it read-only)
- confidence: medium

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: ps3netsrv
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/shawly/ps3netsrv:v2.0.1`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/shawly/docker-ps3netsrv/blob/0585a23954e9b3ca27cc978ddc479af10e363ad1/alpine.Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/aldostools/ps3netsrv)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/aldostools/ps3netsrv/releases/download/20261110/ps3netsrv_20261110_linux.zip)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: amd64 takes ps3netsrv from the release zip (ubuntu amd64 deb inside), arm64 compiles the small C source with gcc and meson. One process, no s6; game folder mounted read-only, no writable state beyond /tmp.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.
- `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.

- **amd64**: yes
- **arm64**: compile

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: no
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
