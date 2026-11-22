# chronograf

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: easy
- **Chart**: chronograf
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/chronograf
- **Source repository**: https://github.com/influxdata/chronograf
- **Documentation**: https://docs.influxdata.com/chronograf/latest/introduction/installation/

## Potentially relevant resources

- **Container image**: https://hub.docker.com/_/chronograf
- **Website**: https://www.influxdata.com/time-series-platform/chronograf

## Base container

- **Primary**: ubuntu
- **Alternative**: none
- **Reason**: Go single binary extracted from the vendor package.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: chronograf
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `chronograf:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/influxdata/influxdata-docker/blob/f49180e6d0f4acee8c9f8672342cf4496d81b99b/chronograf/1.11/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/influxdata/chronograf)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://dl.influxdata.com/chronograf/releases/chronograf_1.11.7_amd64.deb) · [arm64](https://dl.influxdata.com/chronograf/releases/chronograf_1.11.7_arm64.deb)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Go single binary from official influxdata packages. Extract the binary from the .deb onto containerforge-ubuntu, point its data directory at /config, and run one process with no services.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [chronograf:latest](https://hub.docker.com/_/chronograf)
- **copy-from arm64**: [chronograf:latest](https://hub.docker.com/_/chronograf)

### Dependency containers

- **Dependency containers**: none
