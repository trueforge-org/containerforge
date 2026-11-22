# shelfmark

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: medium
- **Chart**: shelfmark
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/shelfmark
- **Source repository**: https://github.com/calibrain/shelfmark

## Potentially relevant resources

- **Container image**: https://ghcr.io/calibrain/shelfmark

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: shelfmark
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/calibrain/shelfmark:v1.7.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/calibrain/shelfmark/blob/0d97110f0132d78147213d11902298c516c32f16/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/calibrain/shelfmark)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/calibrain/shelfmark/releases/tag/v1.7.0)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Python backend in a uv venv, with a node-built frontend copied from a stage and several apt converter and download tools. The python sibling covers the runtime. Lite versus full target mapping is unconfirmed, so the scope could grow.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/calibrain/shelfmark:v1.7.0](https://ghcr.io/calibrain/shelfmark)
- **copy-from arm64**: [ghcr.io/calibrain/shelfmark:v1.7.0](https://ghcr.io/calibrain/shelfmark)

### Dependency containers

- **Dependency containers**: none
