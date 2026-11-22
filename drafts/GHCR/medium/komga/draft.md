# komga

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: medium
- **Chart**: komga
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/komga
- **Source repository**: https://github.com/gotson/komga
- **Documentation**: https://komga.org/docs/introduction

## Potentially relevant resources

- **Container image**: https://ghcr.io/gotson/komga
- **Website**: https://komga.org

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [java21](https://github.com/trueforge-org/containerforge/tree/main/apps/java21) (`ghcr.io/trueforge-org/java21`)
- **Reason**: Spring Boot jar that the draft says should reuse the java21 sibling.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: komga
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/gotson/komga:1.30.1`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/gotson/komga/blob/1.30.1/komga/docker/Dockerfile.tpl)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/gotson/komga)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/gotson/komga/releases/download/1.30.1/komga-1.30.1.jar)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Spring Boot server packaged as a JAR; the upstream build compiles it with Gradle in a java stage. Reuse the java21 sibling, copy the release jar into /app and keep library data in /config. Single process that runs non-root; thumbnails and temp files go to /tmp.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/gotson/komga:1.30.1](https://ghcr.io/gotson/komga)
- **copy-from arm64**: [ghcr.io/gotson/komga:1.30.1](https://ghcr.io/gotson/komga)

### Dependency containers

- **Dependency containers**: none
