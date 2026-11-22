# aistor

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Quay
- **Difficulty**: hard
- **Chart**: aistor
- **Rows**: 1
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **Website**: https://min.io/product/aistor

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: aistor
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `quay.io/minio/aistor/minio:RELEASE.2026-09-19T17-05-25Z`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

`-` means no public Dockerfile could be found.

- **Dockerfile**: -

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://min.io/product/aistor)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://dl.min.io/aistor/minio/release/linux-amd64/minio) · [arm64](https://dl.min.io/aistor/minio/release/linux-arm64/minio)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Closed-source MinIO AIStor with no public Dockerfile, but the vendor publishes linux binaries for download; running needs a license key. Fetch the vendor binary into /app with data under /config; licensing and redistribution terms are the blocker.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [quay.io/minio/aistor/minio:RELEASE.2026-09-19T17-05-25Z](https://quay.io/repository/minio/aistor/minio)
- **copy-from arm64**: [quay.io/minio/aistor/minio:RELEASE.2026-09-19T17-05-25Z](https://quay.io/repository/minio/aistor/minio)

### Dependency containers

- **Dependency containers**: none
