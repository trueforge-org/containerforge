# openbooks

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: medium
- **Chart**: openbooks
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/openbooks
- **Source repository**: https://github.com/evan-buss/openbooks
- **Website**: https://evan-buss.github.io/openbooks/

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: openbooks
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/evan-buss/openbooks:4.5.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/evan-buss/openbooks/blob/045410c2787860e3ce79ae66954e6c1723d185c1/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/evan-buss/openbooks)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/evan-buss/openbooks/releases/download/v4.5.0/openbooks_linux)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Static Go binary: amd64 downloads the v4.5.0 release asset, arm64 needs a Go plus node build stage. Single process, downloads kept in /config, runs rootless with read-only rootfs.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.
- `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.

- **amd64**: yes
- **arm64**: compile

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [ghcr.io/evan-buss/openbooks:4.5.0](https://ghcr.io/evan-buss/openbooks)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
