# hetzner-ddns

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: hetzner-ddns
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/hetzner-ddns
- **Source repository**: https://github.com/kutzilla/docker-hetzner-ddns

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/kutzilla/hetzner-ddns

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Go updater with a small static build stage on ubuntu.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: none
- other: Go toolchain (static build from cmd/hetzner-ddns)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: none

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/hetzner-ddns
- non-root: possible - chart forces runAsUser 0; outbound API client needs no root
- read-only-rootfs: possible - chart sets readOnlyRootFilesystem false; config file only
- privileged: no - common default, not overridden
- other-security: none
- extra-persistence: none (persistence: {})
- confidence: medium

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: hetzner-ddns
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/kutzilla/hetzner-ddns:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/kutzilla/docker-hetzner-ddns/blob/511c911/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/kutzilla/docker-hetzner-ddns)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Go DDNS updater built from cmd/hetzner-ddns in a golang:1.19-alpine stage and copied into alpine, with no release binaries. On containerforge-ubuntu this needs a Go build stage, which is a small static build. Runtime is one process with outbound API calls and a config file.

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
