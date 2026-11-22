# metube

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: medium
- **Chart**: metube
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/metube
- **Source repository**: https://github.com/alexta69/metube

## Potentially relevant resources

- **Container image**: https://ghcr.io/alexta69/metube

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [python](https://github.com/trueforge-org/containerforge/tree/main/apps/python) (`ghcr.io/trueforge-org/python`)
- **Reason**: Python app installed with pip; ffmpeg comes from apt.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: ffmpeg
- python/pip: yt-dlp, aiohttp
- node/npm: web UI build deps (inferred, builder stage)
- other: none

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8081/http (web UI)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/metube
- non-root: yes - runAsUser 568 default, no container override
- read-only-rootfs: yes - default true, not overridden
- privileged: no - default false, not overridden
- other-security: none
- extra-persistence: /downloads (pvc). Draft says downloads go to /config or /tmp, the chart mounts /downloads.
- confidence: medium

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: metube
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/alexta69/metube:2026.11.14`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/alexta69/metube/blob/7746086e0e920925cb14c8f4843084e29548a877/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/alexta69/metube)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/alexta69/metube/releases/tag/2026.11.14)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Python app (yt-dlp, aiohttp) installed with pip into /app, with a node stage that builds the web UI. The python sibling covers the runtime, and ffmpeg comes from apt on ubuntu. Downloads go to /config or /tmp, so the rootless fit is good.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/alexta69/metube:2026.11.14](https://ghcr.io/alexta69/metube)
- **copy-from arm64**: [ghcr.io/alexta69/metube:2026.11.14](https://ghcr.io/alexta69/metube)

### Dependency containers

- **Dependency containers**: none
