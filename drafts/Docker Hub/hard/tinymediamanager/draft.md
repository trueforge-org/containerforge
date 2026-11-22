# tinymediamanager

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: tinymediamanager
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/tinymediamanager
- **Source repository**: https://gitlab.com/tinyMediaManager/tinyMediaManager
- **Documentation**: https://www.tinymediamanager.org/docs/
- **Website**: https://www.tinymediamanager.org/

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/tinymediamanager/tinymediamanager

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [java17](https://github.com/trueforge-org/containerforge/tree/main/apps/java17) (`ghcr.io/trueforge-org/java17`)
- **Alternative runtime image**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`)
- **Reason**: Java desktop app with no Java version named, so java17 is used.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: tinymediamanager
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/tinymediamanager/tinymediamanager:5.3.5`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://gitlab.com/tinyMediaManager/tinyMediaManager/-/blob/a2204fc/src/docker/Dockerfile.amd64)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://gitlab.com/tinyMediaManager/tinyMediaManager)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://www.tinymediamanager.org/download/)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Java desktop app run inside a VNC GUI base image, so it needs a desktop stack (kasmvnc or xvfb). The application is a platform-neutral Java distribution with a bundled JRE path, so the architecture side is easy. The GUI requirement is the effort driver.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [tinymediamanager/tinymediamanager:5.3.5](https://hub.docker.com/r/tinymediamanager/tinymediamanager)
- **copy-from arm64**: [tinymediamanager/tinymediamanager:5.3.5](https://hub.docker.com/r/tinymediamanager/tinymediamanager)

### Dependency containers

- **Dependency containers**: none
