# livestreamdvr

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: livestreamdvr
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/livestreamdvr
- **Source repository**: https://github.com/MrBrax/LiveStreamDVR

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/mrbrax/twitchautomator

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: `ghcr.io/trueforge-org/python-node`
- **Reason**: Needs both a Python server and a Node client, and python-node covers both stacks.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: ffmpeg (inferred)
- python/pip: pipenv (Pipfile); streamlink (inferred)
- node/npm: client deps (inferred)
- other: LiveStreamDVR release zip (2025-01-21 build)

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: livestreamdvr
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/mrbrax/twitchautomator:master`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/MrBrax/LiveStreamDVR/blob/1cd7e8fa5b68e6c0cf9e657d1caa2cc74f7eb814/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/MrBrax/LiveStreamDVR)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/MrBrax/LiveStreamDVR/releases/download/LiveStreamDVR-2025-01-21-c2.4.3-s1.7.5.1-d1.1.2-v2.3.2.1/LiveStreamDVR-2025-01-21-c2.4.3-s1.7.5.1-d1.1.2-v2.3.2.1.zip)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Python with pipenv and a Node client, so it needs the python and node siblings plus ffmpeg and streamlink-style tooling. Sources are pure Python and JS with no native compile, but the server and client are two stacks that must both run from /app with state in /config.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [mrbrax/twitchautomator:master](https://hub.docker.com/r/mrbrax/twitchautomator)
- **copy-from arm64**: [mrbrax/twitchautomator:master](https://hub.docker.com/r/mrbrax/twitchautomator)

### Dependency containers

- **Dependency containers**: none
