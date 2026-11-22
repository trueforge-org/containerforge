# st-reborn-server

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: st-reborn-server
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/st-reborn-server
- **Source repository**: https://github.com/tiltedphoques/TiltedEvolution

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/tiltedphoques/st-reborn-server

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Per-arch release tarball unpacked into /app with no compile.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: none
- other: none

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 10578/udp (game server)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/st-reborn-server
- non-root: yes - runAsUser 568 default, no root override
- read-only-rootfs: yes - default readOnlyRootFilesystem true, not overridden
- privileged: no - common default privileged false, not overridden
- other-security: none
- extra-persistence: /home/server/Data, /home/server/logs (pvc, chart-defined); /home/server/config is chart config
- confidence: medium

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: st-reborn-server
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/tiltedphoques/st-reborn-server:1.8.4`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/tiltedphoques/TiltedEvolution/blob/v1.8.4/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/tiltedphoques/TiltedEvolution)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/tiltedphoques/TiltedEvolution/releases/download/v1.8.4/SkyrimTogetherServer-1.8.4-linux-amd64.tar.gz) · [arm64](https://github.com/tiltedphoques/TiltedEvolution/releases/download/v1.8.4/SkyrimTogetherServer-1.8.4-linux-arm64.tar.gz)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Skyrim Together server ships as per-arch release tarballs (linux-amd64 and linux-arm64), so unpack into /app on containerforge-ubuntu with TARGETARCH and no compile. Game data and config go in /config. Check libraries with ldd, and confirm the server runs rootless with a read-only rootfs.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [tiltedphoques/st-reborn-server:1.8.4](https://hub.docker.com/r/tiltedphoques/st-reborn-server)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
