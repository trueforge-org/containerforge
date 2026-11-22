# plexanisync

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: easy
- **Chart**: plexanisync
- **Rows**: 1
- **Hard dependency containers**: no
- **Soft dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **Source repository**: https://github.com/RickDB/PlexAniSync
- **Documentation**: https://github.com/RickDB/PlexAniSync/wiki

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: plexanisync
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/rickdb/plexanisync:1.4.4`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/RickDB/PlexAniSync/blob/v1.4.4/Docker/PlexAniSync/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/RickDB/PlexAniSync)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/RickDB/PlexAniSync/releases/tag/v1.4.4)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: PlexAniSync is a pure Python sync tool, so the repo can be pip installed into /app on the python sibling and the PyInstaller and staticx steps can be dropped. It runs as one process that keeps its state in /config. Rootless operation is straightforward.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [ghcr.io/rickdb/plexanisync:1.4.4](https://ghcr.io/rickdb/plexanisync)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
