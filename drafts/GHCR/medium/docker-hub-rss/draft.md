# docker-hub-rss

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: medium
- **Chart**: docker-hub-rss
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/docker-hub-rss
- **Source repository**: https://github.com/TheConnMan/docker-hub-rss

## Potentially relevant resources

- **Container image**: https://ghcr.io/theconnman/docker-hub-rss

## Base container

- **Primary**: python-node
- **Alternative**: none
- **Reason**: Small Node.js app with production node_modules.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: docker-hub-rss
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/theconnman/docker-hub-rss:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/TheConnMan/docker-hub-rss/blob/5c8152db7d37641aa589e2e38a656823f8910d51/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/TheConnMan/docker-hub-rss)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/TheConnMan/docker-hub-rss/releases)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: docker-hub-rss is a small Node app that copies the repo source and production node_modules onto the node sibling. It is one process with no database. The main work is building it from the repo without a published version to pin.

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
