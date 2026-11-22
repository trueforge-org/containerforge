# uptime-kuma

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: uptime-kuma
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/uptime-kuma
- **Source repository**: https://github.com/louislam/uptime-kuma
- **Documentation**: https://github.com/louislam/uptime-kuma/wiki

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: uptime-kuma
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/louislam/uptime-kuma:1.23.17-debian`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/louislam/uptime-kuma/blob/1.23.17/docker/dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/louislam/uptime-kuma)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/louislam/uptime-kuma/releases/download/1.23.17/dist.tar.gz)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Node app built with npm ci and a frontend build stage, then copied onto a node base. ContainerForge would reuse the node sibling, run npm ci into /app, and keep the SQLite database in /config. It is a single process with a frontend build step.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [louislam/uptime-kuma:1.23.17-debian](https://hub.docker.com/r/louislam/uptime-kuma)
- **copy-from arm64**: [louislam/uptime-kuma:1.23.17-debian](https://hub.docker.com/r/louislam/uptime-kuma)

### Dependency containers

- **Dependency containers**: none
