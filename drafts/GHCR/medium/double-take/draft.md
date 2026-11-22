# double-take

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: medium
- **Chart**: double-take
- **Rows**: 1
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **Source repository**: https://github.com/jakowenko/double-take

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: double-take
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/skrashevich/double-take:v1.13.11`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/skrashevich/double-take/blob/60c957d/.build/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/jakowenko/double-take)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/jakowenko/double-take/releases/tag/v1.13.2)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Double-Take is a Node API (Dockerfile node:16/18) built with npm and a Vue frontend built with bun, run on the node sibling as one process. It needs cairo/pango libs for canvas, an older Node version, and its storage path moved to /config.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/skrashevich/double-take:v1.13.11](https://ghcr.io/skrashevich/double-take)
- **copy-from arm64**: [ghcr.io/skrashevich/double-take:v1.13.11](https://ghcr.io/skrashevich/double-take)

### Dependency containers

- **Dependency containers**: none
