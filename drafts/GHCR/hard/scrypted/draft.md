# scrypted

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: hard
- **Chart**: scrypted
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/scrypted
- **Source repository**: https://github.com/koush/scrypted
- **Documentation**: https://docs.scrypted.app
- **Website**: https://scrypted.app

## Potentially relevant resources

- **Container image**: https://ghcr.io/koush/scrypted

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: scrypted
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/koush/scrypted:v0.123.58-jammy-full, v0.123.58-jammy-lite, v0.123.58-jammy-nvidia`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/koush/scrypted/blob/main/install/docker/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/koush/scrypted)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: binary: `npm:@scrypted/server`

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Node server installed with npx on the scrypted-common base, which bundles ffmpeg and Python plugin runtimes. The nvidia variant needs CUDA, the base is jammy rather than ubuntu 26.04, and camera and GPU access need hardware. A large stack with hardware access makes it hard.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.
- A trailing `*` means the claim could not be confirmed against the upstream source, so it is a best judgement and should be rechecked before porting.

- **amd64**: yes*
- **arm64**: yes*

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/koush/scrypted:v0.123.58-jammy-full](https://ghcr.io/koush/scrypted)
- **copy-from arm64**: [ghcr.io/koush/scrypted:v0.123.58-jammy-full](https://ghcr.io/koush/scrypted)

### Dependency containers

- **Dependency containers**: none
