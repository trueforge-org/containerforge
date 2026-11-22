# ollama

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: ollama
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: yes (open-webui)
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/ollama
- **Source repository**: https://github.com/ollama/ollama
- **Documentation**: https://docs.ollama.com
- **Website**: https://ollama.com

## Potentially relevant resources

- **Container image**: https://ghcr.io/open-webui/open-webui
- **Source code repository**: https://github.com/open-webui/open-webui
- **Container image**: https://hub.docker.com/r/ollama/ollama

## Base container

- **Foundation**: ubuntu (`ghcr.io/trueforge-org/ubuntu:26.4`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Go binary shipped as a release tarball with bundled libraries.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: ollama
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/ollama/ollama:0.40.16, 0.40.16-rocm`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/ollama/ollama/blob/v0.40.16/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/ollama/ollama)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/ollama/ollama/releases/download/v0.40.16/ollama-linux-amd64-mlx.tar.zst) · [arm64](https://github.com/ollama/ollama/releases/download/v0.40.16/ollama-linux-arm64-jetpack5.tar.zst)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Go binary shipped as a release tarball with its bundled libs, so no compile is needed. Use the ollama tarball with the CPU path and keep models in /config. ROCm and CUDA variants are optional, and the open-webui sidecar adds a separate Python stack.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [ollama/ollama:0.40.16](https://hub.docker.com/r/ollama/ollama)
- **copy-from arm64**: no

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

❌ means it is missing too.

- **Dependency containers**: open-webui (uiImage) ❌
