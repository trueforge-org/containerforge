# local-ai

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: local-ai
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/local-ai
- **Source repository**: https://github.com/mudler/LocalAI
- **Documentation**: https://localai.io/docs/
- **Website**: https://localai.io/

## Potentially relevant resources

- **Source code repository**: https://github.com/go-skynet/LocalAI
- **Container image**: https://hub.docker.com/r/localai/localai

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Go server from release binaries on ubuntu, CPU variant only.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: none
- other: LocalAI v5.0.0 release binary per arch (CPU variant only)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8080/http (OpenAI-compatible API and web UI)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/local-ai
- non-root: no - chart sets runAsUser 0, runAsGroup 0, runAsNonRoot false
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: unknown - no privileged flag in values; CUDA image variants may need GPU device access, which values do not show
- other-security: none in values beyond the CUDA image variants
- extra-persistence: /models (pvc); /images (pvc)
- confidence: high

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: The chart runs v2.28.0 images but the planned binary is v5.0.0, so the image and binary versions are not aligned and must be reconciled (inferred).
- caveat: Model downloads at runtime are multi-gigabyte and make the first start slow; they need internet access or pre-loaded model files (inferred).
- caveat: Only the CPU variant is planned, so GPU-accelerated models will not run in this container.

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: local-ai
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/localai/localai:v2.28.0-cublas-cuda11-core, v2.28.0-cublas-cuda11-ffmpeg-core, v2.28.0-cublas-cuda12-core (+6)`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/mudler/LocalAI/blob/56f44d448ca585642de4ca13f0521c3096268f1f/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/mudler/LocalAI)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/mudler/LocalAI/releases/download/v5.0.0/local-ai-v5.0.0-linux-amd64) · [arm64](https://github.com/mudler/LocalAI/releases/download/v5.0.0/local-ai-v5.0.0-linux-arm64)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Go LocalAI server with a large C++ backend matrix and CUDA/GPU image variants, built from source in the upstream Dockerfile. A CPU-only image could unpack the release binary onto containerforge-ubuntu, but GPU variants need NVIDIA drivers and the stack is large.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [localai/localai:v2.28.0-cublas-cuda11-core](https://hub.docker.com/r/localai/localai)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
