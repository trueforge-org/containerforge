# paperless-ngx

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: paperless-ngx
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/paperless-ngx
- **Source repository**: https://github.com/gotenberg/gotenberg
- **Documentation**: https://paperless-ngx.readthedocs.io/en/latest/

## Potentially relevant resources

- **Container image**: https://ghcr.io/paperless-ngx/paperless-ngx
- **Source code repository**: https://github.com/paperless-ngx/paperless-ngx
- **Container image**: https://hub.docker.com/r/apache/tika
- **Container image**: https://hub.docker.com/r/gotenberg/gotenberg

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: paperless-ngx
- **Role**: sidecar (gotenbergImage)

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/gotenberg/gotenberg:9.9`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/gotenberg/gotenberg/blob/da5d11a1bc50a46afe29e23fed471fa6ed3cf05e/build/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/gotenberg/gotenberg)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Go API built with go build from the upstream recipe; wraps headless Chromium, LibreOffice, pdftk/qpdf, exiftool and fonts, a large runtime stack. Ubuntu ships chromium as a snap, so a non-snap Chromium is needed. Profile dirs go under /tmp.

### amd64 / arm64

How we get the application for that architecture.

- `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.

- **amd64**: compile
- **arm64**: compile

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [gotenberg/gotenberg:9.9](https://hub.docker.com/r/gotenberg/gotenberg)
- **copy-from arm64**: [gotenberg/gotenberg:9.9](https://hub.docker.com/r/gotenberg/gotenberg)

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

- **Dependency containers**: -
