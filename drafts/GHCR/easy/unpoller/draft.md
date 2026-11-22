# unpoller

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: easy
- **Chart**: unpoller
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/unpoller
- **Source repository**: https://github.com/unpoller/unpoller

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: unpoller
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/unpoller/unpoller:v5.9.6`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/unpoller/unpoller/blob/efb5e52aefb26f913cfc17f96d5d9c7ba4772ac2/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/unpoller/unpoller)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/unpoller/unpoller/releases/download/v5.9.6/unpoller_5.9.6_linux_amd64.tar.gz) · [arm64](https://github.com/unpoller/unpoller/releases/download/v5.9.6/unpoller_5.9.6_linux_arm64.tar.gz)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Single Go binary that polls UniFi controllers and exports metrics. Download the release tarball per TARGETARCH into /app, config via env or file in /config; no writable paths beyond /tmp and it runs rootless.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/unpoller/unpoller:v5.9.6](https://ghcr.io/unpoller/unpoller)
- **copy-from arm64**: [ghcr.io/unpoller/unpoller:v5.9.6](https://ghcr.io/unpoller/unpoller)

### Dependency containers

- **Dependency containers**: none
