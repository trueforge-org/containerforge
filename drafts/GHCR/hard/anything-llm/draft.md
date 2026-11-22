# anything-llm

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: hard
- **Chart**: anything-llm
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/anything-llm
- **Source repository**: https://github.com/Mintplex-Labs/anything-llm
- **Documentation**: https://docs.anythingllm.com/
- **Website**: https://anythingllm.com/

## Potentially relevant resources

- **Container image**: https://ghcr.io/mintplex-labs/anything-llm

## Base container

- **Foundation**: ubuntu (`ghcr.io/trueforge-org/ubuntu:26.4`), which every ContainerForge runtime image is built on
- **Runtime image**: python-node
- **Reason**: Node.js monorepo that also needs a Python collector.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: anything-llm
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/mintplex-labs/anything-llm:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/Mintplex-Labs/anything-llm/blob/eb498cf2c211/docker/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/Mintplex-Labs/anything-llm)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/Mintplex-Labs/anything-llm/releases/download/v1.20.0/AnythingLLMDesktop.AppImage) · [arm64](https://github.com/Mintplex-Labs/anything-llm/releases/download/v1.20.0/AnythingLLMDesktop-Arm64.AppImage)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Large Node.js/Yarn monorepo with a Python collector and native deps such as LanceDB and sqlite, built from source in multi-stage Docker on Ubuntu noble. Many moving parts and a large build make it hard, though no CUDA is required.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/mintplex-labs/anything-llm:latest](https://ghcr.io/mintplex-labs/anything-llm)
- **copy-from arm64**: [ghcr.io/mintplex-labs/anything-llm:latest](https://ghcr.io/mintplex-labs/anything-llm)

### Dependency containers

- **Dependency containers**: none
