# ersatztv

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: hard
- **Chart**: ersatztv
- **Rows**: 1
- **Hard dependency containers**: no
- **Soft dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **Source repository**: https://github.com/ErsatzTV/ErsatzTV
- **Documentation**: https://ersatztv.org/docs/

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: ersatztv
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/ersatztv/ersatztv:v25.2.0-nvidia, v25.2.0-vaapi, v26.3.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/ErsatzTV/ErsatzTV/blob/2271d5497becc30f8cf689715d115fb36d0abc8a/docker/nvidia/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/ErsatzTV/ErsatzTV)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/ErsatzTV/ErsatzTV/releases/download/v26.3.0/ErsatzTV-v26.3.0-linux-x64.tar.gz) · [arm64](https://github.com/ErsatzTV/ErsatzTV/releases/download/v26.3.0/ErsatzTV-v26.3.0-linux-arm64.tar.gz)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: ErsatzTV is a .NET server needing its custom ffmpeg (NVENC/VAAPI) variants, so GPU device access and hardware-accelerated ffmpeg make it hard; reuse the ffmpeg sibling where possible and keep the database under /config. No .NET runtime base exists, though upstream release tarballs are self-contained.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [ghcr.io/ersatztv/ersatztv:v25.2.0-nvidia](https://ghcr.io/ersatztv/ersatztv)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
