# quickshare

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: easy
- **Chart**: quickshare
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/quickshare
- **Source repository**: https://github.com/ihexxa/quickshare

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/hexxa/quickshare

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Go binary from the release zip.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: unzip (inferred)
- python/pip: none
- node/npm: none
- other: Go release zip per arch

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 3000/http (web UI and API, inferred)

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: quickshare
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/hexxa/quickshare:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/ihexxa/quickshare/blob/f8216ab/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/ihexxa/quickshare)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/ihexxa/quickshare/releases/download/v0.11.4/quickshare_linux_amd64.zip) · [arm64](https://github.com/ihexxa/quickshare/releases/download/v0.11.4/quickshare_linux_arm64.zip)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Go server with release zips per arch, so unzip the binary into /app on containerforge-ubuntu. Runs as one process, with uploads and data in /config and temp files in /tmp. No services needed.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [hexxa/quickshare:latest](https://hub.docker.com/r/hexxa/quickshare)
- **copy-from arm64**: [hexxa/quickshare:latest](https://hub.docker.com/r/hexxa/quickshare)

### Dependency containers

- **Dependency containers**: none
