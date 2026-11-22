# hammond

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: medium
- **Chart**: hammond
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/hammond
- **Source repository**: https://github.com/AlfHou/hammond

## Potentially relevant resources

- **Container image**: https://ghcr.io/alfhou/hammond
- **Source code repository**: https://github.com/alfhou/hammond/pkgs/container/hammond

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Go API is the runtime process; the Node UI is only a build-stage dependency.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: Node UI build deps (inferred)
- other: Go modules for the Go API

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8080/http (Go API and UI) (inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/hammond
- non-root: yes - common default runAsUser 568, no root override
- read-only-rootfs: yes - common default true; config and assets are pvc mounts
- privileged: no - common default false, no override
- other-security: none
- extra-persistence: /assets (pvc, chart-level)
- confidence: low

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: hammond
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/alfhou/hammond:v0.0.24`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/AlfHou/hammond/blob/c167642b889a7d939e6087d9bda9854d4346ee5c/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/AlfHou/hammond)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Go API and Node UI, each built in its own stage from source, then copied into alpine:latest. Upstream has no release binaries, so we would compile the Go module and build the UI on ubuntu for both arches. Trace confidence is low because the tag was not matched.

### amd64 / arm64

How we get the application for that architecture.

- `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.

- **amd64**: compile
- **arm64**: compile

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: no
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
