# tanoshi

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: tanoshi
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/tanoshi
- **Source repository**: https://github.com/luigi311/tanoshi

## Potentially relevant resources

- **Source code repository**: https://github.com/faldez/tanoshi
- **Container image**: https://hub.docker.com/r/faldez/tanoshi

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Rust toolchain is not provided by any base, so ubuntu is used with cargo from apt.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: cargo, rustc, pkg-config, libssl-dev (inferred)
- python/pip: none
- node/npm: none
- other: trunk and wasm-bindgen via cargo (inferred), git clone of successor fork

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 3579/http (web UI and API)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/tanoshi
- non-root: no - chart sets runAsUser 0, runAsGroup 0
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - default false, no override
- other-security: none
- extra-persistence: none beyond /tanoshi (chart's own config path)
- confidence: high

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: tanoshi
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/faldez/tanoshi:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

`-` means no public Dockerfile could be found.

- **Dockerfile**: -

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/luigi311/tanoshi)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: The faldez repo is gone and the image has no public Dockerfile. The successor fork needs a trunk wasm frontend build plus a cargo build, a multi-stage Rust toolchain on containerforge-ubuntu. The build has to be reproduced and verified against the old image.

### amd64 / arm64

How we get the application for that architecture.

- `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.

- **amd64**: compile
- **arm64**: compile

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [faldez/tanoshi:latest](https://hub.docker.com/r/faldez/tanoshi)
- **copy-from arm64**: [faldez/tanoshi:latest](https://hub.docker.com/r/faldez/tanoshi)

### Dependency containers

- **Dependency containers**: none
