# littlelink

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: medium
- **Chart**: littlelink
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/littlelink
- **Source repository**: https://github.com/timothystewart6/littlelink-server

## Potentially relevant resources

- **Container image**: https://ghcr.io/techno-tim/littlelink-server
- **Source code repository**: https://github.com/sethcottle/littlelink
- **Source code repository**: https://github.com/techno-tim/littlelink-server

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: littlelink
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/techno-tim/littlelink-server:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/techno-tim/littlelink-server/blob/e7fa7dbb3178fcd963e6472f25e96a874f496a11/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/timothystewart6/littlelink-server)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/timothystewart6/littlelink-server/archive/refs/heads/master.tar.gz)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Littlelink is a Next.js app built with yarn in a node stage and run from the standalone output on the node sibling. It is one process with no database and only static config. The frontend build is the main effort.

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
