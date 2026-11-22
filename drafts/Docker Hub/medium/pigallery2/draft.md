# pigallery2

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: pigallery2
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/pigallery2
- **Source repository**: https://github.com/bpatrik/pigallery2

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/bpatrik/pigallery2

## Base container

- **Primary**: python-node
- **Alternative**: none
- **Reason**: Node.js app with native modules built with npm, so python-node provides node.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: pigallery2
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/bpatrik/pigallery2:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/bpatrik/pigallery2/blob/43f348a254142eea521138b783e3b8df9fe547c8/docker/alpine/Dockerfile.build)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/bpatrik/pigallery2)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/bpatrik/pigallery2/releases/download/3.8.0/pigallery2-release.zip)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Node.js photo gallery built from source with npm for both frontend and backend, using native modules for sqlite and image handling. Build is moderate and fits the node sibling, but database and thumbnail paths must move to /config and /tmp; the alpine variant was chosen, so the debian variant is unverified.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: no
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
