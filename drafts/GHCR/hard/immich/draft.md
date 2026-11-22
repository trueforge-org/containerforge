# immich

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: hard
- **Chart**: immich
- **Rows**: 2
- **Hard dependency containers**: no
- **Soft dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **Source repository**: https://github.com/immich-app/immich
- **Documentation**: https://docs.immich.app/
- **Website**: https://immich.app/

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- Row 1: **Chart**: immich
- Row 1: **Role**: main
- Row 2: **Chart**: immich
- Row 2: **Role**: sidecar (mlImage, mlCudaImage)

### Container

The image and tag the chart uses today.

- Row 1: **Container**: `ghcr.io/immich-app/immich-server:v3.4.2`
- Row 2: **Container**: `ghcr.io/immich-app/immich-machine-learning:v3.4.1-openvino, v3.4.2, v3.4.2-cuda (+1)`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- Row 1: **Dockerfile**: [Dockerfile](https://github.com/immich-app/immich/blob/v3.4.2/server/Dockerfile)
- Row 2: **Dockerfile**: [Dockerfile](https://github.com/immich-app/immich/blob/v3.4.1/machine-learning/Dockerfile)

### Application source

The application's own source repository or project page.

- Row 1: **Application source**: [source](https://github.com/immich-app/immich)
- Row 2: **Application source**: [source](https://github.com/immich-app/immich)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- Row 1: **Application binary**: [amd64](https://github.com/immich-app/immich/releases/download/v3.4.2/app-x86_64-release.apk) · [arm64](https://github.com/immich-app/immich/releases/download/v3.4.2/app-arm64-v8a-release.apk)
- Row 2: **Application binary**: [binary](https://github.com/immich-app/immich/archive/refs/tags/v3.4.1.tar.gz (machine-learning/ directory, install with uv))

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- Row 1: **Difficulty**: hard
- Row 2: **Difficulty**: hard

### Reason

- Row 1: **Reason**: Large stack: a Node/TypeScript server, web and CLI built with pnpm from source, plus Postgres (CNPG), Valkey and a separate machine-learning service with CUDA variants. Several services and a GPU variant, root in the source image, and a rootless rework make it hard.
- Row 2: **Reason**: Python 3.13 service installed with uv from the v3.4.1 source on the python sibling, with large model and onnxruntime wheels. CPU build works on amd64 and arm64; OpenVINO and CUDA variants are amd64 only. Models cache in /config or /tmp.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.
- A trailing `*` means the claim could not be confirmed against the upstream source, so it is a best judgement and should be rechecked before porting.

- Row 1: **amd64**: yes*
- Row 1: **arm64**: yes*
- Row 2: **amd64**: yes
- Row 2: **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- Row 1: **copy-from amd64**: [ghcr.io/immich-app/immich-server:v3.4.2](https://ghcr.io/immich-app/immich-server)
- Row 1: **copy-from arm64**: [ghcr.io/immich-app/immich-server:v3.4.2](https://ghcr.io/immich-app/immich-server)
- Row 2: **copy-from amd64**: [ghcr.io/immich-app/immich-machine-learning:v3.4.1-openvino](https://ghcr.io/immich-app/immich-machine-learning)
- Row 2: **copy-from arm64**: no

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, CNPG PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

❌ means it is missing too.

- Row 1: **Dependency containers**: valkey ✅, postgresql (CNPG) ✅, immich-machine-learning (mlImage, mlCudaImage, mlOpenvinoImage…) ❌
- Row 2: **Dependency containers**: -
