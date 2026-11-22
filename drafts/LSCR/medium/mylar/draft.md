# mylar

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: LSCR
- **Difficulty**: medium
- **Chart**: mylar
- **Rows**: 1
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **Source repository**: https://github.com/MylarComics/mylar3

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: mylar
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `lscr.io/linuxserver/mylar3:version-v0.11.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/linuxserver/docker-mylar3/blob/0a973d043b16789a002ada4441e87aa1dcbd3b0c/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/MylarComics/mylar3)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/MylarComics/mylar3/releases/tag/v0.11.0)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Python web app (mylar3) installed from a release tarball with pip deps in a venv, plus a unrar binary copied from a linuxserver stage. Port to the python stack with app code in /app, config and database in /config, and the unrar binary built or taken from Ubuntu apt.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [lscr.io/linuxserver/mylar3:version-v0.11.0](https://ghcr.io/linuxserver/mylar3)
- **copy-from arm64**: [lscr.io/linuxserver/mylar3:version-v0.11.0](https://ghcr.io/linuxserver/mylar3)

### Dependency containers

- **Dependency containers**: none
