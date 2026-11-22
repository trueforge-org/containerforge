# searxng

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: searxng
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/searxng
- **Source repository**: https://github.com/searxng/searxng
- **Documentation**: https://docs.searxng.org/

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/searxng/searxng

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [python](https://github.com/trueforge-org/containerforge/tree/main/apps/python) (`ghcr.io/trueforge-org/python`)
- **Reason**: Python app installed with uv into a venv, and the input names the python sibling.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: build-essential, libxslt-dev, zlib1g-dev, libffi-dev, libssl-dev (inferred)
- python/pip: uv (inferred), searxng upstream requirements ([requirements.txt](https://github.com/searxng/searxng/blob/HEAD/requirements.txt))
- node/npm: none
- other: none

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8080/http (web UI and API)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/searxng
- non-root: no - runAsUser 0, runAsGroup 0 override; s6 init with SETUID/SETGID
- read-only-rootfs: possible - inherits default true, but app writes must go to /tmp (common default) and the chart config is /etc/searxng
- privileged: no - common default privileged false, not overridden
- other-security: capabilities add SETUID, SETGID; disableS6Caps true
- extra-persistence: none beyond chart config /etc/searxng (pvc)
- confidence: medium

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: searxng
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/searxng/searxng:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/searxng/searxng/blob/1ebea4a073ec6011bae25c042d97308278184c83/container/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/searxng/searxng)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/searxng/searxng/releases)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Python app installed with uv into a venv on the searxng base image, with a valkey option. Reuse python and install from the upstream source, then run as one process. Settings and cache must move to /config and /tmp.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [searxng/searxng:latest](https://hub.docker.com/r/searxng/searxng)
- **copy-from arm64**: [searxng/searxng:latest](https://hub.docker.com/r/searxng/searxng)

### Dependency containers

- **Dependency containers**: none
