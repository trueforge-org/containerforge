# chroma

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: easy
- **Chart**: chroma
- **Rows**: 1
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: chroma
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/chroma-core/chroma:1.5.9`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/chroma-core/chroma/blob/11f3c7435e71024aa0a2b53710a28d3289d922d1/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/chroma-core/chroma)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: binary: `pip:chromadb`

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Python chroma server installed by pip, with its rust extension shipped as prebuilt wheels. The python sibling covers the runtime, and data goes to /config. One pip install with no extra services makes it easy.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/chroma-core/chroma:1.5.9](https://ghcr.io/chroma-core/chroma)
- **copy-from arm64**: [ghcr.io/chroma-core/chroma:1.5.9](https://ghcr.io/chroma-core/chroma)

### Dependency containers

- **Dependency containers**: none
