# broadcast-box

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: broadcast-box
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/broadcast-box
- **Source repository**: https://github.com/Glimesh/broadcast-box

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/seaduboi/broadcast-box

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Alternative runtime image**: `ghcr.io/trueforge-org/python-node`
- **Reason**: Go server with a Node-built UI on ubuntu; the Node runtime for the build is the alternative.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: none (UI build deps not named)
- other: go toolchain (compile), node toolchain for UI build (inferred)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8080/http (web UI and API), 8189/udp (WebRTC media)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/broadcast-box
- non-root: no - chart sets container runAsUser 0 and runAsGroup 0
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - common default false, no override in values
- other-security: UDP service port 60006 (no capability or hostNetwork override)
- extra-persistence: none (no persistence section, common defaults only)
- confidence: high

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: broadcast-box
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `seaduboi/broadcast-box:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/Glimesh/broadcast-box/blob/484a22832dcea141ff3ac984f2f038cacf8aa678/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/Glimesh/broadcast-box)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Go WebRTC streaming server plus a Node-built web UI, both built in separate stages. Port needs both builds on ContainerForge bases and a glibc runtime; modest moving parts and UDP ports.

### amd64 / arm64

How we get the application for that architecture.

- `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.

- **amd64**: compile
- **arm64**: compile

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: no
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
