# comet

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: medium
- **Chart**: comet
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: yes (postgresql)
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/comet
- **Source repository**: https://github.com/g0ldyy/comet

## Potentially relevant resources

- **Container image**: https://ghcr.io/g0ldyy/comet

## Base container

- **Foundation**: ubuntu (`ghcr.io/trueforge-org/ubuntu:26.4`), which every ContainerForge runtime image is built on
- **Runtime image**: python
- **Reason**: Python FastAPI app installed into a venv.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: comet
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/g0ldyy/comet:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/g0ldyy/comet/blob/a3b75ecbefc494747c30ab484ff86c07c61585f0/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/g0ldyy/comet)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/g0ldyy/comet/releases/tag/v2.59.0)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Python FastAPI add-on; upstream builds a venv with uv in a builder stage that carries a Rust toolchain for some dependencies. Reuse the python sibling, install into /app and keep caches in /tmp. Dependencies without an arm64 wheel would compile on arm64, which adds build time.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.
- A trailing `*` means the claim could not be confirmed against the upstream source, so it is a best judgement and should be rechecked before porting.

- **amd64**: yes*
- **arm64**: yes*

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/g0ldyy/comet:latest](https://ghcr.io/g0ldyy/comet)
- **copy-from arm64**: [ghcr.io/g0ldyy/comet:latest](https://ghcr.io/g0ldyy/comet)

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

- **Dependency containers**: postgresql ✅
