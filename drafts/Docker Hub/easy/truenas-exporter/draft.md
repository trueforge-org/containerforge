# truenas-exporter

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: easy
- **Chart**: truenas-exporter
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/truenas-exporter
- **Source repository**: https://github.com/prometheus/graphite_exporter

## Potentially relevant resources

- **Source code repository**: https://github.com/Supporterino/truenas-graphite-to-prometheus/tree/main
- **Container image**: https://hub.docker.com/r/prom/graphite-exporter

## Base container

- **Primary**: ubuntu
- **Alternative**: none
- **Reason**: Prometheus Go exporter binary from the release tarball.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: truenas-exporter
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/prom/graphite-exporter:v0.17.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/prometheus/graphite_exporter/blob/v0.17.0/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/prometheus/graphite_exporter)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/prometheus/graphite_exporter/releases/download/v0.17.0/graphite_exporter-0.17.0.dragonfly-amd64.tar.gz) · [arm64](https://github.com/prometheus/graphite_exporter/releases/download/v0.17.0/graphite_exporter-0.17.0.linux-arm64.tar.gz)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Prometheus graphite exporter Go binary, copied from the upstream prebuilt release. It runs as a single process on a non-root port with no state. Wrap it in containerforge-ubuntu with the binary in /app.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [prom/graphite-exporter:v0.17.0](https://hub.docker.com/r/prom/graphite-exporter)
- **copy-from arm64**: [prom/graphite-exporter:v0.17.0](https://hub.docker.com/r/prom/graphite-exporter)

### Dependency containers

- **Dependency containers**: none
