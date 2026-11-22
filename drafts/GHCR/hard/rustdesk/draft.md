# rustdesk

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: hard
- **Chart**: rustdesk
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/rustdesk
- **Source repository**: https://github.com/rustdesk-org/rustdesk-server
- **Documentation**: https://rustdesk.com/docs/en/self-host/
- **Website**: https://rustdesk.com/

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: rustdesk
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/rustdesk/rustdesk-server-s6:1.1.16`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/rustdesk-org/rustdesk-server/blob/1.1.16/docker/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/rustdesk-org/rustdesk-server)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/rustdesk/rustdesk-server/releases/download/1.1.16/rustdesk-server-linux-amd64.zip) · [arm64](https://github.com/rustdesk/rustdesk-server/releases/download/1.1.16/rustdesk-server-linux-arm64v8.zip)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: The RustDesk server image runs two daemons, hbbs and hbbr, under s6 on a busybox base. Both are Rust binaries that would be fetched from release assets. The multi-process layout, several ports and s6 supervision make this a hard port.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/rustdesk/rustdesk-server-s6:1.1.16](https://ghcr.io/rustdesk/rustdesk-server-s6)
- **copy-from arm64**: [ghcr.io/rustdesk/rustdesk-server-s6:1.1.16](https://ghcr.io/rustdesk/rustdesk-server-s6)

### Dependency containers

- **Dependency containers**: none
