# cadquery-server

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: cadquery-server
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/cadquery-server
- **Source repository**: https://github.com/roipoussiere/cadquery-server

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: cadquery-server
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/cadquery/cadquery-server:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/roipoussiere/cadquery-server/blob/fe634393ae00cb271aca935a119a560b01140362/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/roipoussiere/cadquery-server)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: binary: `pip:cadquery-server`

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Python service that pip installs cadquery and OCP (OpenCASCADE bindings), a heavy native stack, from the copied source on python:3.10. Use the python sibling with a Python version that has the wheels; run rootless with caches in /tmp.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [cadquery/cadquery-server:latest](https://hub.docker.com/r/cadquery/cadquery-server)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
