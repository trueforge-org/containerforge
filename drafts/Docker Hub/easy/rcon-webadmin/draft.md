# rcon-webadmin

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: easy
- **Chart**: rcon-webadmin
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/rcon-webadmin
- **Source repository**: https://github.com/rcon-web-admin/rcon-web-admin

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/itzg/rcon

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: `ghcr.io/trueforge-org/python-node`
- **Reason**: Node web admin installed with npm, so the python-node base provides Node.js.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: npm install of release source (deps from package.json, inferred)
- other: release source tarball

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: rcon-webadmin
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/itzg/rcon:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/itzg/docker-rcon-web-admin/blob/484fba3/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/rcon-web-admin/rcon-web-admin)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/rcon-web-admin/rcon-web-admin/releases/tag/0.14.1)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Node web admin for Minecraft RCON, installed from the release source tarball with one npm install into /app on a node sibling, then started from src/main.js. Upstream uses node:12, so a current node runtime is needed. No extra services, and config goes to /config.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [itzg/rcon:latest](https://hub.docker.com/r/itzg/rcon)
- **copy-from arm64**: [itzg/rcon:latest](https://hub.docker.com/r/itzg/rcon)

### Dependency containers

- **Dependency containers**: none
