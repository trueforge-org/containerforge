# wyoming-piper

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: easy
- **Chart**: wyoming-piper
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/wyoming-piper
- **Source repository**: https://github.com/rhasspy/wyoming-piper
- **Documentation**: https://www.home-assistant.io/integrations/piper/

## Potentially relevant resources

- **Source code repository**: https://github.com/home-assistant/addons/tree/master/piper
- **Container image**: https://hub.docker.com/r/rhasspy/wyoming-piper

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [python](https://github.com/trueforge-org/containerforge/tree/main/apps/python) (`ghcr.io/trueforge-org/python`)
- **Reason**: Python Wyoming server for Piper TTS installed from pip.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: wyoming-piper, piper-tts (inferred)
- node/npm: none
- other: voice model downloads at runtime (optional)

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: wyoming-piper
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/rhasspy/wyoming-piper:2.5.4`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/rhasspy/wyoming-piper/blob/0ed34210e8c6f73f39c0d725ffb020f73b4fd312/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/rhasspy/wyoming-piper)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: binary: `pip:wyoming-piper`

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Python Wyoming server for Piper TTS installed from pip into a venv, with no extra services. Reuse the piper sibling and keep voice models under /config. Runs as one process.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [rhasspy/wyoming-piper:2.5.4](https://hub.docker.com/r/rhasspy/wyoming-piper)
- **copy-from arm64**: [rhasspy/wyoming-piper:2.5.4](https://hub.docker.com/r/rhasspy/wyoming-piper)

### Dependency containers

- **Dependency containers**: none
