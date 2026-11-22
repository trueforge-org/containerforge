# signal-cli-rest-api

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: signal-cli-rest-api
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/signal-cli-rest-api
- **Source repository**: https://github.com/bbernhard/signal-cli-rest-api
- **Documentation**: https://bbernhard.github.io/signal-cli-rest-api/

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/bbernhard/signal-cli-rest-api

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: signal-cli-rest-api
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/bbernhard/signal-cli-rest-api:0.101`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/bbernhard/signal-cli-rest-api/blob/0.101/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/bbernhard/signal-cli-rest-api)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Go REST server built from source, plus the signal-cli Java tarball on openjdk 25. ContainerForge has a java25 sibling. We would add a Go build stage, and the JVM runs as a child process in one container with state under /config.

### amd64 / arm64

How we get the application for that architecture.

- `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.

- **amd64**: compile
- **arm64**: compile

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [bbernhard/signal-cli-rest-api:0.101](https://hub.docker.com/r/bbernhard/signal-cli-rest-api)
- **copy-from arm64**: [bbernhard/signal-cli-rest-api:0.101](https://hub.docker.com/r/bbernhard/signal-cli-rest-api)

### Dependency containers

- **Dependency containers**: none
