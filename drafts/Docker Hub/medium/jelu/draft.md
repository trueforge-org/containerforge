# jelu

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: jelu
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/jelu
- **Source repository**: https://github.com/bayang/jelu
- **Documentation**: https://bayang.github.io/jelu-web/

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/wabayang/jelu

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [java17](https://github.com/trueforge-org/containerforge/tree/main/apps/java17) (`ghcr.io/trueforge-org/java17`)
- **Reason**: The input names the java17 sibling for a Spring Boot jar.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: none
- other: Java 17 runtime (java17 base); jelu-0.88.4.jar release download

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: jelu
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/wabayang/jelu:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/bayang/jelu/blob/2aba1840c9d823851a5d219dcf9802e1a194a4e2/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/bayang/jelu)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/bayang/jelu/releases/download/v0.88.4/jelu-0.88.4.jar)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Spring Boot Java book manager that runs on the java17 sibling. The Dockerfile copies pre-extracted layers built outside it, so ContainerForge must rebuild the JAR from source or use the upstream release jar. Data goes to /config and the app is one process.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.
- A trailing `*` means the claim could not be confirmed against the upstream source, so it is a best judgement and should be rechecked before porting.

- **amd64**: yes*
- **arm64**: yes*

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [wabayang/jelu:latest](https://hub.docker.com/r/wabayang/jelu)
- **copy-from arm64**: [wabayang/jelu:latest](https://hub.docker.com/r/wabayang/jelu)

### Dependency containers

- **Dependency containers**: none
