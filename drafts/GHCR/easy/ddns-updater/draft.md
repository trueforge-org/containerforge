# ddns-updater

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: easy
- **Chart**: ddns-updater
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/ddns-updater
- **Source repository**: https://github.com/qdm12/ddns-updater
- **Documentation**: https://github.com/qdm12/ddns-updater/tree/master/docs

## Potentially relevant resources

- **Container image**: https://ghcr.io/qdm12/ddns-updater

## Base container

- **Primary**: ubuntu
- **Alternative**: none
- **Reason**: Go binary from the release file run directly on ubuntu.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: ddns-updater
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/qdm12/ddns-updater:v2.10.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/qdm12/ddns-updater/blob/v2.10.0/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/qdm12/ddns-updater)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/qdm12/ddns-updater/releases/download/v2.10.0/ddns-updater_2.10.0_linux_amd64) · [arm64](https://github.com/qdm12/ddns-updater/releases/download/v2.10.0/ddns-updater_2.10.0_linux_arm64)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: DDNS Updater is a Go binary released for every Linux arch, so the release file is fetched by TARGETARCH on containerforge-ubuntu. It is one process that writes its config and cache to /config. Nothing else is needed.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/qdm12/ddns-updater:v2.10.0](https://ghcr.io/qdm12/ddns-updater)
- **copy-from arm64**: [ghcr.io/qdm12/ddns-updater:v2.10.0](https://ghcr.io/qdm12/ddns-updater)

### Dependency containers

- **Dependency containers**: none
