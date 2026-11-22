# minecraft-gate

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: easy
- **Chart**: minecraft-gate
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/minecraft-gate
- **Source repository**: https://github.com/minekube/gate
- **Documentation**: https://gate.minekube.com
- **Documentation**: https://gate.minekube.com/
- **Website**: https://minekube.com/

## Potentially relevant resources

- **Container image**: https://ghcr.io/minekube/gate

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Go static binary released for amd64 and arm64.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: none
- other: release binary (gate_0.82.0_linux_amd64 / _arm64)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 25565/tcp (Minecraft proxy)

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: minecraft-gate
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/minekube/gate:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/minekube/gate/blob/f47fd8c3ec6f/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/minekube/gate)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/minekube/gate/releases/download/v0.82.0/gate_0.82.0_linux_amd64) · [arm64](https://github.com/minekube/gate/releases/download/v0.82.0/gate_0.82.0_linux_arm64)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Minekube Gate Minecraft proxy written in Go and released as static binaries. Copy the binary into /app on containerforge-ubuntu with config in /config; the jre variant is a separate target. Release assets were not re-checked because GitHub returned 429 during this run.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/minekube/gate:latest](https://ghcr.io/minekube/gate)
- **copy-from arm64**: [ghcr.io/minekube/gate:latest](https://ghcr.io/minekube/gate)

### Dependency containers

- **Dependency containers**: none
