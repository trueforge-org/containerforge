# counterstrike2d

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: medium
- **Chart**: counterstrike2d
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/counterstrike2d
- **Website**: https://www.cs2d.com/

## Potentially relevant resources

- **Container image**: https://ghcr.io/ich777/cs2dserver
- **Steam store page**: https://www.steampowered.com

## Base container

- **Primary**: ubuntu
- **Alternative**: none
- **Reason**: Vendor server downloaded at runtime and unzipped with a start script.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: counterstrike2d
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/ich777/cs2dserver:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/ich777/docker-cs2d-server/blob/master/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://www.cs2d.com/)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://www.cs2d.com/download.php)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Closed-source freeware CS2D server fetched from the vendor at runtime; the ich777 wrapper runs as root and unzips the download. Reuse the wrapper pattern on containerforge-ubuntu with a start script that downloads to /config and writes only there.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [ghcr.io/ich777/cs2dserver:latest](https://ghcr.io/ich777/cs2dserver)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
