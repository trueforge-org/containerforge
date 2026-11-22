# kdenlive

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: LSCR
- **Difficulty**: hard
- **Chart**: kdenlive
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/kdenlive
- **Source repository**: https://github.com/KDE/kdenlive
- **Documentation**: https://docs.kdenlive.org/
- **Website**: https://kdenlive.org

## Potentially relevant resources

- **Container image**: https://fleet.linuxserver.io/image?name=linuxserver/kdenlive
- **Source code repository**: https://github.com/linuxserver/docker-kdenlive#readme
- **Source code repository**: https://github.com/orgs/linuxserver/packages/container/package/kdenlive

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: kdenlive
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `lscr.io/linuxserver/kdenlive:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/linuxserver/docker-kdenlive/blob/f39884e7d1d55d31dd0babb973c1cb0ea066d84f/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/KDE/kdenlive)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: binary: `apt:kdenlive`

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: KDE video editor GUI installed with pacman on a linuxserver selkies desktop base, so this is a desktop image needing a display session. The Ubuntu archive has kdenlive for both arches, so the package is available and the desktop setup is the effort driver.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [lscr.io/linuxserver/kdenlive:latest](https://ghcr.io/linuxserver/kdenlive)
- **copy-from arm64**: [lscr.io/linuxserver/kdenlive:latest](https://ghcr.io/linuxserver/kdenlive)

### Dependency containers

- **Dependency containers**: none
