# farmos

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: farmos
- **Rows**: 1
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **Source repository**: https://github.com/farmOS/farmOS
- **Documentation**: https://farmOS.org/hosting/install
- **Website**: https://farmOS.org

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: farmos
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/farmos/farmos:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/farmOS/farmOS/blob/c09e3f403a21e2c3073dd5db686981c99e0314b7/docker/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/farmOS/farmOS)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/farmOS/farmOS/releases/download/3.5.11/farmOS-3.5.11.tar.gz)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Drupal 11 PHP application built with composer from git on a drupal apache base. ContainerForge has no PHP app, so PHP, apache or php-fpm and composer must be built on containerforge-ubuntu, plus a database. Several moving parts and a large dependency tree.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [farmos/farmos:latest](https://hub.docker.com/r/farmos/farmos)
- **copy-from arm64**: [farmos/farmos:latest](https://hub.docker.com/r/farmos/farmos)

### Dependency containers

- **Dependency containers**: none
