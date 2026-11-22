# tubesync

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: hard
- **Chart**: tubesync
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/tubesync
- **Source repository**: https://github.com/meeb/tubesync

## Potentially relevant resources

- **Container image**: https://ghcr.io/meeb/tubesync
- **Container image**: https://registry.hub.docker.com/r/ghcr.io/meeb/tubesync

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [python](https://github.com/trueforge-org/containerforge/tree/main/apps/python) (`ghcr.io/trueforge-org/python`)
- **Alternative runtime image**: [nginx](https://github.com/trueforge-org/containerforge/tree/main/apps/nginx) (`ghcr.io/trueforge-org/nginx`)
- **Reason**: Django app on Python, run with gunicorn, nginx and background workers.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: ffmpeg, nginx (inferred)
- python/pip: Django requirements, gunicorn, yt-dlp (inferred)
- node/npm: none
- other: source checkout of tag v0.19.1; s6-overlay (inferred)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8080/http (web UI, inferred)

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: tubesync
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/meeb/tubesync:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/meeb/tubesync/blob/d3f65687276f/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/meeb/tubesync)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/meeb/tubesync/releases/tag/v0.19.1)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Python Django app run under s6-overlay with several processes: gunicorn, nginx and background workers, plus ffmpeg and yt-dlp. s6 and multiple services in one image make it hard, and download paths must be moved into /config or /tmp.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/meeb/tubesync:latest](https://ghcr.io/meeb/tubesync)
- **copy-from arm64**: [ghcr.io/meeb/tubesync:latest](https://ghcr.io/meeb/tubesync)

### Dependency containers

- **Dependency containers**: none
