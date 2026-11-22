# leaf2mqtt

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: medium
- **Chart**: leaf2mqtt
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/leaf2mqtt
- **Source repository**: https://github.com/mitsumaui/leaf2mqtt

## Potentially relevant resources

- **Container image**: https://ghcr.io/k8s-at-home/leaf2mqtt
- **Source code repository**: https://github.com/k8s-at-home/container-images

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Dart app is compiled ahead-of-time to a native binary.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: none
- other: Dart SDK (inferred, AOT compile stage)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: none

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: leaf2mqtt
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/k8s-at-home/leaf2mqtt:v0.6`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/mitsumaui/leaf2mqtt/blob/v0.6/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/mitsumaui/leaf2mqtt)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Dart app compiled ahead-of-time in a builder stage and copied onto scratch, per the upstream master Dockerfile. ContainerForge would need a Dart SDK stage and the v0.6 mapping is unconfirmed. Single process with MQTT config in /config, so a modest source build. Medium.

### amd64 / arm64

How we get the application for that architecture.

- `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.

- **amd64**: compile
- **arm64**: compile

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/k8s-at-home/leaf2mqtt:v0.6](https://ghcr.io/k8s-at-home/leaf2mqtt)
- **copy-from arm64**: [ghcr.io/k8s-at-home/leaf2mqtt:v0.6](https://ghcr.io/k8s-at-home/leaf2mqtt)

### Dependency containers

- **Dependency containers**: none
