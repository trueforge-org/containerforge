# photoprism

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: photoprism
- **Rows**: 1
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **Source repository**: https://github.com/photoprism/photoprism

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: photoprism
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/photoprism/photoprism:251130`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/photoprism/photoprism/blob/master/docker/photoprism/questing/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/photoprism/photoprism)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/photoprism/photoprism/releases/download/261029-963b58c50/photoprism_261029-963b58c50-linux-amd64.tar.gz) · [arm64](https://github.com/photoprism/photoprism/releases/download/261029-963b58c50/photoprism_261029-963b58c50-linux-arm64.tar.gz)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Go binary with bundled UI and TensorFlow libs, version 251130; install the upstream prebuilt tarball on containerforge-ubuntu with TARGETARCH, no compile. Needs MariaDB (existing mariadb app) as a separate service; upstream defaults to root and /photoprism paths, so move originals, storage and cache to /config and /tmp.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [photoprism/photoprism:251130](https://hub.docker.com/r/photoprism/photoprism)
- **copy-from arm64**: [photoprism/photoprism:251130](https://hub.docker.com/r/photoprism/photoprism)

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, CNPG PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

- **Dependency containers**: mariadb ✅
