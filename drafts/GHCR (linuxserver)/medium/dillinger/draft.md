# dillinger

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR (linuxserver)
- **Difficulty**: medium
- **Chart**: dillinger
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/dillinger
- **Source repository**: https://github.com/joemccann/dillinger
- **Website**: https://www.dillinger.io/
- **Website**: https://dillinger.io/

## Potentially relevant resources

- **Container image**: https://ghcr.io/linuxserver/dillinger

## Base container

- **Primary**: python-node
- **Alternative**: none
- **Reason**: Node.js editor built with npm, so python-node provides the runtime.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: dillinger
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/linuxserver/dillinger:3.39.1`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/linuxserver/docker-dillinger/blob/1d1b7d5f198a81964e0e2b1428ba7d6bd4b1526e/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/joemccann/dillinger)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: binary: `npm:dillinger`

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Dillinger Node markdown editor from a GitHub source tarball, with npm dependencies and a modest frontend build, on the linuxserver alpine 3.18 base. Reuse the node sibling and serve from /app with state in /config. Medium: a frontend build but no extra services.

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
