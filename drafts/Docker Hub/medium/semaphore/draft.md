# semaphore

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: semaphore
- **Rows**: 1
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **Source repository**: https://github.com/semaphoreui/semaphore
- **Documentation**: https://semaphoreui.com/docs/

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: semaphore
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/semaphoreui/semaphore:v2.20.24`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/semaphoreui/semaphore/blob/7cf38e07fa33532defa12db82b847b2ee4e6ea6f/deployment/docker/server/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/semaphoreui/semaphore)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/semaphoreui/semaphore/releases/download/v2.20.23/semaphore_2.20.23_linux_amd64.tar.gz) · [arm64](https://github.com/semaphoreui/semaphore/releases/download/v2.20.23/semaphore_2.20.23_linux_arm64.tar.gz)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Go server with a prebuilt release tarball that is easy to install, but the image also bundles OpenTofu, Terraform, Terragrunt and ansible. Those tools must be added as extra binaries and pip packages. Postgres is an external dependency.

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

Other containers the chart needs (Chart.yaml dependencies, CNPG PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

- **Dependency containers**: postgresql (CNPG) ✅
