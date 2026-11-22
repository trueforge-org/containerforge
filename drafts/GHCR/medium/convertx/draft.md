# convertx

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: medium
- **Chart**: convertx
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/convertx
- **Source repository**: https://github.com/C4illin/ConvertX

## Potentially relevant resources

- **Container image**: https://ghcr.io/c4illin/convertx
- **Source code repository**: https://github.com/c4illin/ConvertX

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Alternative runtime image**: `ghcr.io/trueforge-org/python-node`
- **Reason**: Runs on bun with apt-installed converters and no bun base exists, so ubuntu is a guess.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: imagemagick, ffmpeg, pandoc
- python/pip: none
- node/npm: none
- other: bun runtime and bun deps (inferred)

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: convertx
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/c4illin/convertx:v0.20.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/C4illin/ConvertX/blob/42224e3f1f1ad0eb6e6d2bac661a5b3f2b2a2976/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/C4illin/ConvertX)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/C4illin/ConvertX/archive/refs/tags/v0.20.0.tar.gz)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Bun/TypeScript web app that converts files by calling many system tools such as ImageMagick, ffmpeg and pandoc, installed with apt. Upstream bundles it with bun compile, but the same source runs under bun. Medium for the number of converter tools to install.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/c4illin/convertx:v0.20.0](https://ghcr.io/c4illin/convertx)
- **copy-from arm64**: [ghcr.io/c4illin/convertx:v0.20.0](https://ghcr.io/c4illin/convertx)

### Dependency containers

- **Dependency containers**: none
