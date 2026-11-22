# plex-meta-manager

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: plex-meta-manager
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/plex-meta-manager
- **Source repository**: https://github.com/meisnate12/Plex-Meta-Manager
- **Documentation**: https://metamanager.wiki/
- **Documentation**: https://kometa.wiki/en/latest/

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/meisnate12/plex-meta-manager

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [python](https://github.com/trueforge-org/containerforge/tree/main/apps/python) (`ghcr.io/trueforge-org/python`)
- **Reason**: Python script app installed with pip requirements.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: requirements.txt from repo ([requirements.txt](https://github.com/meisnate12/Plex-Meta-Manager/blob/HEAD/requirements.txt))
- node/npm: none
- other: none

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: none

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/plex-meta-manager
- non-root: no - runAsUser 0, runAsNonRoot false in values
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - common default false, not overridden
- other-security: none
- extra-persistence: none beyond /config
- confidence: medium

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: A config.yml must be created by the user before the first run; the app does not create a working config by itself (inferred).
- caveat: It needs a Plex token plus TMDb, TVDB or similar API keys, supplied by the user.
- caveat: The first full run downloads metadata for the whole library and can take a long time (inferred).

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: plex-meta-manager
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/meisnate12/plex-meta-manager:v1.21.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/meisnate12/Plex-Meta-Manager/blob/v1.21.0/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/meisnate12/Plex-Meta-Manager)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/meisnate12/Plex-Meta-Manager/releases/tag/v1.21.0)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Python script app at v1.21.0 with pip requirements installed onto python:3.11-slim-buster, with the source copied via COPY . /. Reuse the python sibling on ubuntu, install into /app, and keep config and cache under /config and /tmp. Many dependencies but no services or compile.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [meisnate12/plex-meta-manager:v1.21.0](https://hub.docker.com/r/meisnate12/plex-meta-manager)
- **copy-from arm64**: [meisnate12/plex-meta-manager:v1.21.0](https://hub.docker.com/r/meisnate12/plex-meta-manager)

### Dependency containers

- **Dependency containers**: none
