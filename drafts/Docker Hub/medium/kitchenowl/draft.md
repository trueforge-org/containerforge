# kitchenowl

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: kitchenowl
- **Rows**: 2
- **Hard dependency containers**: no
- **Soft dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **Source repository**: https://github.com/TomBursch/kitchenowl
- **Documentation**: https://docs.kitchenowl.org
- **Website**: https://kitchenowl.org

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- Row 1: **Chart**: kitchenowl
- Row 1: **Role**: main
- Row 2: **Chart**: kitchenowl
- Row 2: **Role**: sidecar (backendImage)

### Container

The image and tag the chart uses today.

- Row 1: **Container**: `docker.io/tombursch/kitchenowl-web:v0.8.1`
- Row 2: **Container**: `docker.io/tombursch/kitchenowl:v0.8.1`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- Row 1: **Dockerfile**: [Dockerfile](https://github.com/TomBursch/kitchenowl/blob/v0.8.1/kitchenowl/Dockerfile)
- Row 2: **Dockerfile**: [Dockerfile](https://github.com/TomBursch/kitchenowl/blob/v0.8.1/backend/Dockerfile)

### Application source

The application's own source repository or project page.

- Row 1: **Application source**: [source](https://github.com/TomBursch/kitchenowl)
- Row 2: **Application source**: [source](https://github.com/TomBursch/kitchenowl)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- Row 1: **Application binary**: [binary](https://github.com/TomBursch/kitchenowl/releases/download/v0.8.1/kitchenowl_Web.tar.gz)
- Row 2: **Application binary**: [binary](https://github.com/TomBursch/kitchenowl/archive/refs/tags/v0.8.1.tar.gz)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- Row 1: **Difficulty**: medium
- Row 2: **Difficulty**: medium

### Reason

- Row 1: **Reason**: Python Flask backend (pip, python sibling) plus a Flutter web frontend served by nginx. Upstream ships kitchenowl_Web.tar.gz as a prebuilt web bundle, so no Flutter build is needed; needs PostgreSQL and two images, and /config for data.
- Row 2: **Reason**: Python 3.14 Flask backend installed with uv; reuse ContainerForge python base and build a venv under /app/venv. Needs a writable /config for SQLite and uploads, plus migrations at start; modest moving parts.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- Row 1: **amd64**: yes
- Row 1: **arm64**: yes
- Row 2: **amd64**: yes
- Row 2: **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- Row 1: **copy-from amd64**: no
- Row 1: **copy-from arm64**: no
- Row 2: **copy-from amd64**: [tombursch/kitchenowl:v0.8.1](https://hub.docker.com/r/tombursch/kitchenowl)
- Row 2: **copy-from arm64**: [tombursch/kitchenowl:v0.8.1](https://hub.docker.com/r/tombursch/kitchenowl)

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, CNPG PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

❌ means it is missing too.

- Row 1: **Dependency containers**: postgresql (CNPG) ✅, kitchenowl (backendImage) ❌
- Row 2: **Dependency containers**: -
