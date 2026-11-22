# qbitrr

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: qbitrr
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/qbitrr
- **Source repository**: https://github.com/Feramance/qBitrr
- **Documentation**: https://feramance.github.io/qBitrr/

## Potentially relevant resources

- **Source code repository**: https://github.com/Feramance/Qbitrr
- **Container image**: https://hub.docker.com/r/feramance/qbitrr

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [python](https://github.com/trueforge-org/containerforge/tree/main/apps/python) (`ghcr.io/trueforge-org/python`)
- **Alternative runtime image**: `ghcr.io/trueforge-org/python-node`
- **Reason**: Python package installed with pip, with a webui built in a node stage.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: qbitrr (pip install .[fast]); qbitrr2 (arm64)
- node/npm: webui build (inferred)
- other: none

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: qbitrr
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/feramance/qbitrr:v5.12.12`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/Feramance/qBitrr/blob/1fe2bc6ee0e27a2f84be0fb78edfabe259266ecf/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/Feramance/qBitrr)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/Feramance/qBitrr/releases/download/v5.12.12/qBitrr-ea67bf65-ubuntu-latest-x64.tar.gz) · arm64: `pip:qbitrr2`

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Python package installed with pip install .[fast] into /app, plus a webui built in a node stage. Needs the ContainerForge python and node bases and a build step. Runs as one process, with config and the database kept in /config.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [feramance/qbitrr:v5.12.12](https://hub.docker.com/r/feramance/qbitrr)
- **copy-from arm64**: [feramance/qbitrr:v5.12.12](https://hub.docker.com/r/feramance/qbitrr)

### Dependency containers

- **Dependency containers**: none
