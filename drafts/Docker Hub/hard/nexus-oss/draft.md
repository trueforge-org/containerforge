# nexus-oss

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: nexus-oss
- **Rows**: 1
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: nexus-oss
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/sonatype/nexus3:3.98.3`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/sonatype/docker-nexus3/blob/aa22a3b/Dockerfile.java21)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/sonatype/nexus-public)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://download.sonatype.com/nexus/3/nexus-3.98.3-01-linux-x86_64.tar.gz) · [arm64](https://download.sonatype.com/nexus/3/nexus-3.98.3-01-linux-aarch_64.tar.gz)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Large Java stack (Nexus 3 with its own bundled JRE and data store) and the public Dockerfile is deprecated, pinned to an older version. Its default image runs root-era paths and needs substantial rework for rootless and read-only operation.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [sonatype/nexus3:3.98.3](https://hub.docker.com/r/sonatype/nexus3)
- **copy-from arm64**: [sonatype/nexus3:3.98.3](https://hub.docker.com/r/sonatype/nexus3)

### Dependency containers

- **Dependency containers**: none
