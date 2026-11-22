# timetagger

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: easy
- **Chart**: timetagger
- **Rows**: 1
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **Source repository**: https://github.com/almarklein/timetagger
- **Website**: https://timetagger.app/

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: timetagger
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/almarklein/timetagger:v26.1.3-nonroot`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/almarklein/timetagger/blob/681720d84c94be660f30947db4b23e52d36cbe32/deploy/repo.nonroot.Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/almarklein/timetagger)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: binary: `pip:timetagger`

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Pure Python app installed with pip from the repo copy into /app, and the upstream nonroot Dockerfile already runs as a non-root user. The python sibling covers the runtime and data goes to /config. No native deps or extra services.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/almarklein/timetagger:v26.1.3-nonroot](https://ghcr.io/almarklein/timetagger)
- **copy-from arm64**: [ghcr.io/almarklein/timetagger:v26.1.3-nonroot](https://ghcr.io/almarklein/timetagger)

### Dependency containers

- **Dependency containers**: none
