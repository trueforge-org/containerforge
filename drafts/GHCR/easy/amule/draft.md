# amule

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: easy
- **Chart**: amule
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/amule
- **Source repository**: https://github.com/amule-org/amule
- **Documentation**: https://amule-org.github.io/docs
- **Website**: https://amule-org.github.io/

## Potentially relevant resources

- **Container image**: https://ghcr.io/ngosang/amule
- **Source code repository**: https://github.com/ngosang/docker-amule

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: amule
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/ngosang/amule:3.2.0-1`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/ngosang/docker-amule/blob/3.2.0-1/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/amule-org/amule)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/amule-org/amule/releases/download/3.2.0/aMule-3.2.0-Linux-x64-static.tar.gz) · [arm64](https://github.com/amule-org/amule/releases/download/3.2.0/aMule-3.2.0-Linux-arm64-static.tar.gz)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: C++ eMule-compatible daemon with a web interface. Upstream is source only, but Ubuntu 26.04 apt amule-daemon (amuled and amuleweb) installs on amd64 and arm64, so no compile is needed. The packaged version may lag upstream; state goes under /config.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/ngosang/amule:3.2.0-1](https://ghcr.io/ngosang/amule)
- **copy-from arm64**: [ghcr.io/ngosang/amule:3.2.0-1](https://ghcr.io/ngosang/amule)

### Dependency containers

- **Dependency containers**: none
