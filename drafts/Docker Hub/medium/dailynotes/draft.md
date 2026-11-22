# dailynotes

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: dailynotes
- **Rows**: 1
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: dailynotes
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/m0ngr31/dailynotes:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/djedi/DailyNotes/blob/9d1a3a7ea3597d93b2c8c4600437318a59eaa028/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/djedi/DailyNotes)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/djedi/DailyNotes/archive/refs/tags/2026.10.29-00.tar.gz)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Python server installed with pip and a Node client built with npm in a builder stage, then copied into python:3.10-slim. On containerforge-ubuntu we would use the python and node siblings and run the npm build into /app, with data under /config. Two runtimes make the build more involved.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [m0ngr31/dailynotes:latest](https://hub.docker.com/r/m0ngr31/dailynotes)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
