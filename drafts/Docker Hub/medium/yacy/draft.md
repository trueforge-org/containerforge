# yacy

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: yacy
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/yacy
- **Source repository**: https://github.com/yacy/yacy_search_server
- **Documentation**: https://yacy.net/docs/
- **Documentation**: https://yacy.net/download_installation/
- **Website**: https://yacy.net/

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/yacy/yacy_search_server

## Base container

- **Primary**: java25
- **Alternative**: java21
- **Reason**: Upstream names Java 24, which is not a listed base; java25 is the newest available and runs Java 24 class files.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: yacy
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/yacy/yacy_search_server:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/yacy/yacy_search_server/blob/eba3f94b4376180de5fbf3812c41e3c65dad4cfb/docker/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/yacy/yacy_search_server)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://download.yacy.net/yacy_v1.942_202608150808_f9c4b9700.tar.gz)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Java search server that runs on the java sibling (Java 24 in upstream), with a builder stage that compiles YaCy from source. A release tarball or JAR can be used instead, with data under /config. The app is a single process but writes many files.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.
- A trailing `*` means the claim could not be confirmed against the upstream source, so it is a best judgement and should be rechecked before porting.

- **amd64**: yes*
- **arm64**: yes*

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [yacy/yacy_search_server:latest](https://hub.docker.com/r/yacy/yacy_search_server)
- **copy-from arm64**: [yacy/yacy_search_server:latest](https://hub.docker.com/r/yacy/yacy_search_server)

### Dependency containers

- **Dependency containers**: none
