# actualserver

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: medium
- **Chart**: actualserver
- **Rows**: 1
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **Source repository**: https://github.com/actualbudget/actual
- **Documentation**: https://actualbudget.org/docs/
- **Website**: https://actualbudget.org/

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: actualserver
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/actualbudget/actual:26.11.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/actualbudget/actual/blob/1766241e3f4b3c578e424c4fa15f1eb83c0da17d/packages/sync-server/docker/alpine.Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/actualbudget/actual)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/actualbudget/actual/releases/download/v26.11.0/Actual-linux-x86_64.AppImage) · [arm64](https://github.com/actualbudget/actual/releases/download/v26.11.0/Actual-linux-arm64.AppImage)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Node sync-server from the actual yarn workspace, copied into a prod stage with npm deps. The node sibling covers the runtime, and data stays in /config as one process. The build spans a yarn workspace, so it is more than a single npm install.

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
