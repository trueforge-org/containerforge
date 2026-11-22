# wyoming-openwakeword

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: easy
- **Chart**: wyoming-openwakeword
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/wyoming-openwakeword
- **Source repository**: https://github.com/rhasspy/wyoming-openwakeword

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: wyoming-openwakeword
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/rhasspy/wyoming-openwakeword:2.1.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/rhasspy/wyoming-openwakeword/blob/456fdcc4c4e2205f629f48127b49b7acf845666c/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/rhasspy/wyoming-openwakeword)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: binary: `pip:wyoming-openwakeword`

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Python Wyoming server installed from pip into a venv, with no extra services. Reuse the python sibling and keep models under /config. Runs as one process on a single port.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [rhasspy/wyoming-openwakeword:2.1.0](https://hub.docker.com/r/rhasspy/wyoming-openwakeword)
- **copy-from arm64**: [rhasspy/wyoming-openwakeword:2.1.0](https://hub.docker.com/r/rhasspy/wyoming-openwakeword)

### Dependency containers

- **Dependency containers**: none
