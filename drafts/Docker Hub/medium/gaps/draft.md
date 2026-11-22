# gaps

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: gaps
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/gaps
- **Source repository**: https://github.com/JasonHHouse/gaps

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/housewrecker/gaps

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [java11](https://github.com/trueforge-org/containerforge/tree/main/apps/java11) (`ghcr.io/trueforge-org/java11`)
- **Reason**: Java app with java11 named in the reason.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: none
- other: GapsAsJar release zip (jar download), Java runtime from java11 base

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8080/http (web UI)

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: gaps
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/housewrecker/gaps:x64-v0.10.4`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/JasonHHouse/gaps/blob/v0.10.4/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/JasonHHouse/gaps)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/JasonHHouse/gaps/releases/download/v0.10.4/GapsAsJar-0.10.4.zip)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Java app whose prebuilt GapsWeb jar is copied into a temurin jre11 image. ContainerForge has java11, so run the jar on containerforge-ubuntu with config in /config. One process and no native code; the jar is built outside the Dockerfile.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [housewrecker/gaps:x64-v0.10.4](https://hub.docker.com/r/housewrecker/gaps)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
