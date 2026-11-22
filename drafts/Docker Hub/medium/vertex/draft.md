# vertex

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: vertex
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/vertex
- **Source repository**: https://github.com/vertex-app/vertex

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: vertex
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/lswl/vertex:stable`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/vertex-app/vertex/blob/ec6fa1e6de502b8069ee0416d397ca419713473e/docker/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/vertex-app/vertex)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/vertex-app/vertex/archive/refs/heads/master.zip)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Node torrent-client web UI built with npm ci in a stage and copied onto the lswl vertex-base image. On containerforge-ubuntu we would reuse the node sibling, run npm ci into /app, and keep data under /config. It has a few moving parts for its UI and daemon.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [lswl/vertex:stable](https://hub.docker.com/r/lswl/vertex)
- **copy-from arm64**: [lswl/vertex:stable](https://hub.docker.com/r/lswl/vertex)

### Dependency containers

- **Dependency containers**: none
