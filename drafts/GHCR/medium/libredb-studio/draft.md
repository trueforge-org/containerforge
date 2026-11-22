# libredb-studio

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: medium
- **Chart**: libredb-studio
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/libredb-studio
- **Source repository**: https://github.com/libredb/libredb-studio
- **Website**: https://libredb.org
- **Website**: https://libredb.org/

## Potentially relevant resources

- **Container image**: https://ghcr.io/libredb/libredb-studio
- **Source code repository**: https://github.com/libredb/libredb-studio/pkgs/container/libredb-studio

## Base container

- **Primary**: python-node
- **Alternative**: none
- **Reason**: Next.js app built with bun and run on the node sibling.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: libredb-studio
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/libredb/libredb-studio:1.3.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/libredb/libredb-studio/blob/58adba536f0283fecb7b761053cb2401dd7187eb/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/libredb/libredb-studio)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/libredb/libredb-studio/releases/download/1.3.0/libredb-studio-desktop-1.3.0-linux-x64.AppImage) · [arm64](https://github.com/libredb/libredb-studio/releases/download/1.3.0/libredb-studio-desktop-1.3.0-linux-arm64.AppImage)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Next.js database studio built with bun and served from the standalone output on node trixie-slim. Reuse the node sibling and run as non-root with state in /tmp or /config. A large frontend build and database client connections make it medium, not hard.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/libredb/libredb-studio:1.3.0](https://ghcr.io/libredb/libredb-studio)
- **copy-from arm64**: [ghcr.io/libredb/libredb-studio:1.3.0](https://ghcr.io/libredb/libredb-studio)

### Dependency containers

- **Dependency containers**: none
