# blog

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: blog
- **Rows**: 1
- **Hard dependency containers**: yes (postgresql)
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/blog
- **Source repository**: https://github.com/m1k1o/blog

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: blog
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/m1k1o/blog:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/m1k1o/blog/blob/f778915ab85f7ea86e1f35e60e5acecfbc90a15f/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/m1k1o/blog)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/m1k1o/blog/releases/tag/v1.5.0)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Simple PHP blog copied into php:8.5-apache with PHP extensions installed in the Dockerfile. ContainerForge has no PHP base, so we would apt install php and apache and run on port 8080 rootless. It uses an external Postgres via PostgreSQL and is one web process with config in /config.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [m1k1o/blog:latest](https://hub.docker.com/r/m1k1o/blog)
- **copy-from arm64**: [m1k1o/blog:latest](https://hub.docker.com/r/m1k1o/blog)

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

- **Dependency containers**: postgresql ✅
