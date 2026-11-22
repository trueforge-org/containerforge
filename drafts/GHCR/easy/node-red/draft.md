# node-red

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: easy
- **Chart**: node-red
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/node-red
- **Source repository**: https://github.com/node-red/node-red
- **Documentation**: https://nodered.org/docs/

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: node-red
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/node-red/node-red:5.0.10`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/node-red/node-red-docker/blob/69e4248/.docker/Dockerfile.debian)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/node-red/node-red)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: binary: `npm:node-red`

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Node-RED flow editor installed with one npm command (npm install node-red) on the ContainerForge node base. Flows and settings live in /config, and palette nodes install there too. Runs as one non-root Node process.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/node-red/node-red:5.0.10](https://ghcr.io/node-red/node-red)
- **copy-from arm64**: [ghcr.io/node-red/node-red:5.0.10](https://ghcr.io/node-red/node-red)

### Dependency containers

- **Dependency containers**: none
