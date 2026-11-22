# rss-bridge

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: medium
- **Chart**: rss-bridge
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/rss-bridge
- **Source repository**: https://github.com/RSS-Bridge/rss-bridge
- **Documentation**: https://rss-bridge.github.io/rss-bridge/index.html

## Potentially relevant resources

- **Container image**: https://ghcr.io/rss-bridge/rss-bridge

## Base container

- **Primary**: ubuntu
- **Alternative**: none
- **Reason**: PHP web app run with PHP packages from apt.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: rss-bridge
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/rss-bridge/rss-bridge:2025-06-03`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/RSS-Bridge/rss-bridge/blob/98e03011dbb80ea9cea3ef8c5e29a1778f169cc9/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/RSS-Bridge/rss-bridge)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/RSS-Bridge/rss-bridge/releases/tag/2025-06-03)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: RSS-Bridge is a PHP web app that can run from apt php packages on containerforge-ubuntu with a single web process. A curl-impersonate helper is also needed. PHP is not a ContainerForge sibling, so the runtime is the main new piece.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/rss-bridge/rss-bridge:2025-06-03](https://ghcr.io/rss-bridge/rss-bridge)
- **copy-from arm64**: [ghcr.io/rss-bridge/rss-bridge:2025-06-03](https://ghcr.io/rss-bridge/rss-bridge)

### Dependency containers

- **Dependency containers**: none
