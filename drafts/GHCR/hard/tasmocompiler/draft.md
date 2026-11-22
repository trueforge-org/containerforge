# tasmocompiler

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: hard
- **Chart**: tasmocompiler
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/tasmocompiler
- **Source repository**: https://github.com/benzino77/tasmocompiler

## Potentially relevant resources

- **Container image**: https://ghcr.io/benzino77/tasmocompiler

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: `ghcr.io/trueforge-org/python-node`
- **Reason**: Node.js app that calls PlatformIO, a Python tool, so python-node covers both.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: git, python3-venv (inferred)
- python/pip: platformio (inferred)
- node/npm: project dependencies from the tasmocompiler repo (inferred)
- other: git checkout of tag v14.0.3; PlatformIO toolchains download at runtime

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: tasmocompiler
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/benzino77/tasmocompiler:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/benzino77/tasmocompiler/blob/1c863599ac02b435ffb2e8aa907fff9da5829296/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/benzino77/tasmocompiler)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/benzino77/tasmocompiler/releases/tag/v14.0.3)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Node app that builds Tasmota firmware by calling PlatformIO, which downloads large toolchains at runtime into a writable home directory. That needs rework for a read-only rootfs and /tmp caching, and the many moving tools make it hard. The node sibling covers the runtime.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/benzino77/tasmocompiler:latest](https://ghcr.io/benzino77/tasmocompiler)
- **copy-from arm64**: [ghcr.io/benzino77/tasmocompiler:latest](https://ghcr.io/benzino77/tasmocompiler)

### Dependency containers

- **Dependency containers**: none
