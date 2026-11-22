# webp-server

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: easy
- **Chart**: webp-server
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/webp-server
- **Source repository**: https://github.com/webp-sh/webp_server_go
- **Documentation**: https://docs.webp.sh/

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/webpsh/webps

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Go standalone linux binaries copied into /app.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: none
- other: release binary webp-server-linux-{amd64,arm64} 0.16.2

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 3333/http (image server)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/webp-server
- non-root: possible - chart sets runAsUser 0, but a Go binary on port 3333 needs no root
- read-only-rootfs: possible - chart sets false; draft writes cache to /tmp and config to /config
- privileged: no - not set, common default false
- other-security: none
- extra-persistence: /opt/pics (pvc, read-only source images) if served from there; /opt/exhaust (pvc, cache) only if cache is not moved off to /tmp
- confidence: medium

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: webp-server
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/webpsh/webps:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/webp-sh/webp_server_go/blob/5efe1bf88814f86588d4c0f030a12d071d7471ae/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/webp-sh/webp_server_go)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/webp-sh/webp_server_go/releases/download/0.16.2/webp-server-linux-amd64) · [arm64](https://github.com/webp-sh/webp_server_go/releases/download/0.16.2/webp-server-linux-arm64)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Go webp server shipped as standalone linux binaries for amd64 and arm64, so ContainerForge can copy the binary into /app. Caches go to /tmp and config to /config. It is a single process.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [webpsh/webps:latest](https://hub.docker.com/r/webpsh/webps)
- **copy-from arm64**: [webpsh/webps:latest](https://hub.docker.com/r/webpsh/webps)

### Dependency containers

- **Dependency containers**: none
