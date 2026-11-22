# simply-shorten

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: simply-shorten
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/simply-shorten
- **Source repository**: https://gitlab.com/draganczukp/simply-shorten

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: simply-shorten
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/draganczukp/simply-shorten:1.1`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://gitlab.com/draganczukp/simply-shorten/-/blob/1.1/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://gitlab.com/draganczukp/simply-shorten)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://gitlab.com/draganczukp/simply-shorten/-/releases)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Java URL shortener built with Gradle in a gradle:jdk14 stage and the jar copied onto openjdk:14 slim. Needs a Gradle build step and a Java runtime from the java sibling (java17 instead of EOL JDK 14); single process with storage in /config.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [draganczukp/simply-shorten:1.1](https://hub.docker.com/r/draganczukp/simply-shorten)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
