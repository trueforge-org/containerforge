# quiz-game

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: quiz-game
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/quiz-game
- **Source repository**: https://github.com/ASKJR/quiz-game

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/patrickstigler/quiz-game
- **Container image**: https://registry.hub.docker.com/r/patrickstigler/quiz-game

## Base container

- **Primary**: nginx
- **Alternative**: python-node
- **Reason**: Node build produces static files that nginx serves.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: quiz-game
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/patrickstigler/quiz-game:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/patrickstigler/quiz-game/blob/dd31e4d29accfa9f22ced2164a90d7394d89a374/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/ASKJR/quiz-game)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/ASKJR/quiz-game)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Node build stage that produces static JS, then nginx serves the output, so the node sibling plus nginx sibling cover it. The upstream file is ASKJR/quiz-game, not the Docker Hub fork, so pin that repo, and the output is arch-independent.

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
