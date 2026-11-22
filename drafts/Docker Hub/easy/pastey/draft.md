# pastey

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: easy
- **Chart**: pastey
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/pastey
- **Source repository**: https://github.com/Cesura/pastey

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/cesura/pastey

## Base container

- **Primary**: python
- **Alternative**: none
- **Reason**: Flask app installed with pip from requirements.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: pastey
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/cesura/pastey:0.5.1, 0.5.1-slim`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/Cesura/pastey/blob/533dda7ad7d8b20407d0bc750f1dbdbb69308d1c/Dockerfile-slim)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/Cesura/pastey)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/Cesura/pastey/releases/tag/0.5.1)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Small Flask paste service with requirements installed by pip and app.py run from copied source on python:3.8 slim, one process. Use the python sibling, pip install requirements into /app and store pastes in /config.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [cesura/pastey:0.5.1](https://hub.docker.com/r/cesura/pastey)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
