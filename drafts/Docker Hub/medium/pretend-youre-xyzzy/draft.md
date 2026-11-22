# pretend-youre-xyzzy

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: pretend-youre-xyzzy
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/pretend-youre-xyzzy
- **Source repository**: https://github.com/ajanata/PretendYoureXyzzy

## Potentially relevant resources

- **Source code repository**: https://github.com/Cyb3r-Jak3/DockerYourXyzzy
- **Container image**: https://hub.docker.com/r/cyb3rjak3/dockeryourxyzzy

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [java17](https://github.com/trueforge-org/containerforge/tree/main/apps/java17) (`ghcr.io/trueforge-org/java17`)
- **Reason**: Java web app with no Java version named, so java17 is the default.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: pretend-youre-xyzzy
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/cyb3rjak3/dockeryourxyzzy:on-demand-v2.1.1`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/Cyb3r-Jak3/DockerYourXyzzy/blob/fade38c9e0b94c1294360a1f4697ab167dbd3d09/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/ajanata/PretendYoureXyzzy)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/ajanata/PretendYoureXyzzy)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Java web app (PretendYoureXyzzy) built from source with Maven on a Tomcat base, and the Java stack already exists in ContainerForge (java8 to java25). Needs a Maven build step and state in /config, but it is a single Tomcat process.

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
