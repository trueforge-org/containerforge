# wyoming-whisper

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: easy
- **Chart**: wyoming-whisper
- **Rows**: 1
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: wyoming-whisper
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/rhasspy/wyoming-whisper:3.9.1`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/rhasspy/wyoming-faster-whisper/blob/1c407106530e09fc8f2477e4ae4cf86480fd6256/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/rhasspy/wyoming-faster-whisper)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: binary: `pip:wyoming-faster-whisper`

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Python Wyoming server using faster-whisper installed from pip into a venv on a debian-slim base, with no extra services. Models go to /config and cache to /tmp. Runs as one process.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [rhasspy/wyoming-whisper:3.9.1](https://hub.docker.com/r/rhasspy/wyoming-whisper)
- **copy-from arm64**: [rhasspy/wyoming-whisper:3.9.1](https://hub.docker.com/r/rhasspy/wyoming-whisper)

### Dependency containers

- **Dependency containers**: none
