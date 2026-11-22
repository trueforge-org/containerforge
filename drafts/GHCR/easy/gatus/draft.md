# gatus

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: easy
- **Chart**: gatus
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/gatus
- **Source repository**: https://github.com/home-operations/gatus-sidecar
- **Documentation**: https://gatus.io
- **Documentation**: https://gatus.io/docs
- **Website**: https://gatus.io/

## Potentially relevant resources

- **Container image**: https://ghcr.io/home-operations/gatus-sidecar
- **Container image**: https://ghcr.io/twin/gatus
- **Source code repository**: https://github.com/TwiN/gatus

## Base container

- **Foundation**: ubuntu (`ghcr.io/trueforge-org/ubuntu:26.4`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Go controller built with a golang stage and copied onto ubuntu.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: gatus
- **Role**: sidecar (sidecarImage)

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/home-operations/gatus-sidecar:0.6.1`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/home-operations/gatus-sidecar/blob/1aefae52150e/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/home-operations/gatus-sidecar)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Static Go controller built with a single go build in a golang stage on containerforge-ubuntu, then copied into /app. Stateless, rootless and read-only friendly.

### amd64 / arm64

How we get the application for that architecture.

- `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.

- **amd64**: compile
- **arm64**: compile

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/home-operations/gatus-sidecar:0.6.1](https://ghcr.io/home-operations/gatus-sidecar)
- **copy-from arm64**: [ghcr.io/home-operations/gatus-sidecar:0.6.1](https://ghcr.io/home-operations/gatus-sidecar)

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

- **Dependency containers**: -
