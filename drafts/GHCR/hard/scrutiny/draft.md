# scrutiny

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: hard
- **Chart**: scrutiny
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/scrutiny
- **Source repository**: https://github.com/AnalogJ/scrutiny

## Potentially relevant resources

- **Container image**: https://ghcr.io/analogj/scrutiny

## Base container

- **Primary**: ubuntu
- **Alternative**: none
- **Reason**: Prebuilt Go binaries plus smartmontools from apt.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: scrutiny
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/analogj/scrutiny:v0.10.0-omnibus`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/AnalogJ/scrutiny/blob/3ae9db201f5c51751d4b6779593f90144a128bf0/docker/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/AnalogJ/scrutiny)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/AnalogJ/scrutiny/releases/download/v0.10.0/scrutiny-collector-metrics-linux-amd64) · [arm64](https://github.com/AnalogJ/scrutiny/releases/download/v0.10.0/scrutiny-collector-metrics-linux-arm64)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Omnibus image with Go web and collector binaries, smartmontools and an embedded influxdb. It needs privileged raw disk access for smartctl and runs several services together. The hardware access and privileged mode make this hard.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/analogj/scrutiny:v0.10.0-omnibus](https://ghcr.io/analogj/scrutiny)
- **copy-from arm64**: [ghcr.io/analogj/scrutiny:v0.10.0-omnibus](https://ghcr.io/analogj/scrutiny)

### Dependency containers

- **Dependency containers**: none
