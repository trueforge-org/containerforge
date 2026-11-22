# game-server-watcher

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: medium
- **Chart**: game-server-watcher
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/game-server-watcher
- **Source repository**: https://github.com/a-sync/game-server-watcher

## Potentially relevant resources

- **Container image**: https://ghcr.io/a-sync/game-server-watcher

## Base container

- **Primary**: python-node
- **Alternative**: none
- **Reason**: Node 20 app with no other runtime needs, so the node-providing base fits.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: game-server-watcher
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/a-sync/game-server-watcher:v3.1.26`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/a-sync/game-server-watcher/blob/2010cd81bc2354d7b3ad10dabd44e340440ac3a5/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/a-sync/game-server-watcher)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: binary: `npm:game-server-watcher`

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Node 20 app built with an npm build step, then /app and prod deps copied into a node image. The node sibling covers the runtime with no external services. Upstream runs as root, so it needs a rootless port and state moved to /config.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [ghcr.io/a-sync/game-server-watcher:v3.1.26](https://ghcr.io/a-sync/game-server-watcher)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
