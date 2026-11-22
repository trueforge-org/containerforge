# commento-plusplus

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: medium
- **Chart**: commento-plusplus
- **Rows**: 1
- **Hard dependency containers**: yes (postgresql)
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/commento-plusplus
- **Source repository**: https://github.com/souramoo/commentoplusplus

## Potentially relevant resources

- **Container image**: https://ghcr.io/souramoo/commentoplusplus

## Base container

- **Primary**: ubuntu
- **Alternative**: python-node
- **Reason**: Go API binary runs on ubuntu; the node frontend is a build-time stage.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: commento-plusplus
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/souramoo/commentoplusplus:v1.8.7`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/souramoo/commentoplusplus/blob/v1.8.7/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/souramoo/commentoplusplus)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Commento++ has a Go API and a node-built frontend, both built from source, and the release tarball is source-level rather than a binary. It is a single process that needs PostgreSQL from PostgreSQL. The build stages and the old alpine:3.13 base are the main work.

### amd64 / arm64

How we get the application for that architecture.

- `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.

- **amd64**: compile
- **arm64**: compile

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: no
- **copy-from arm64**: no

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

- **Dependency containers**: postgresql ✅
