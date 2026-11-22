# kromgo

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: medium
- **Chart**: kromgo
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/kromgo
- **Source repository**: https://github.com/home-operations/kromgo

## Potentially relevant resources

- **Container image**: https://ghcr.io/home-operations/kromgo

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Go service with a compiled binary; no language base needed at runtime.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: npm (inferred, frontend assets)
- other: Go toolchain (inferred, builder stage)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8080/http (badge endpoint, inferred), 8888/http (metrics, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/kromgo
- non-root: yes - runAsUser 568 default, no container override
- read-only-rootfs: yes - default true, not overridden
- privileged: no - default false, not overridden
- other-security: none
- extra-persistence: none (config.yaml configmap at /config/config.yaml)
- confidence: high

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: kromgo
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/home-operations/kromgo:0.16.4`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/home-operations/kromgo/blob/5a14ed14fff8/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/home-operations/kromgo)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Go service with node-built assets; upstream runs on distroless nonroot and publishes only container images. Build in a builder stage on containerforge-ubuntu, run one process that reads Prometheus and writes nothing under /app.

### amd64 / arm64

How we get the application for that architecture.

- `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.

- **amd64**: compile
- **arm64**: compile

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/home-operations/kromgo:0.16.4](https://ghcr.io/home-operations/kromgo)
- **copy-from arm64**: [ghcr.io/home-operations/kromgo:0.16.4](https://ghcr.io/home-operations/kromgo)

### Dependency containers

- **Dependency containers**: none
