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

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Go binary shipped as a release tarball with bundled libraries.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: zstd (inferred)
- python/pip: none
- node/npm: none
- other: ollama release tarball (bundled libs)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 11434/http (API, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/ollama
- non-root: no - runAsUser 0, runAsNonRoot false in values
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - common default false, not overridden
- other-security: none in values; ROCm/CUDA variants may need GPU device access, not shown in values
- extra-persistence: /app/backend/data (data, pvc default) for the optional UI sidecar; /root/.ollama is the chart's config mount
- confidence: medium

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: Model downloads are large (multi-GB per model) and happen at first pull, so the first start needs internet and disk under /config.
- caveat: The arm64 tarball is the jetpack5 build for NVIDIA Jetson, which may not run on generic arm64 hosts (inferred).
- caveat: The pinned 0.40.16 is an old release; newer models may need a newer ollama (inferred).
- caveat: GPU (ROCm/CUDA) variants need device passthrough that the chart values do not show.

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
