# guide2go

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: guide2go
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/guide2go
- **Source repository**: https://github.com/mar-mei/guide2go

## Potentially relevant resources

- **Source code repository**: https://github.com/alturismo/guide2go
- **Container image**: https://hub.docker.com/r/alturismo/guide2go

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Go CLI compiled from source on ubuntu.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: none
- other: Go toolchain; build from source (mar-mei/guide2go)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: none

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/guide2go
- non-root: possible - chart forces runAsUser 0; Go CLI writing to /config needs no root
- read-only-rootfs: possible - chart sets readOnlyRootFilesystem false; draft writes only to /config
- privileged: no - common default, not overridden
- other-security: none
- extra-persistence: /guide2go (pvc), /TVH (pvc)
- confidence: medium

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: guide2go
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/alturismo/guide2go:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/alturismo/guide2go/blob/master/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/mar-mei/guide2go)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Go CLI that builds EPG data for Plex or Emby. The image copies a binary from the build context, and we could not locate a release with assets, so we would compile it from mar-mei/guide2go with Go. Otherwise it is a single process writing to /config.

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
