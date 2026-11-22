# gravity

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: hard
- **Chart**: gravity
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/gravity
- **Source repository**: https://github.com/BeryJu/gravity
- **Documentation**: https://gravity.beryju.io/docs/
- **Website**: https://gravity.beryju.io/

## Potentially relevant resources

- **Container image**: https://ghcr.io/beryju/gravity

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Go server compiled from source.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: gravity
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/beryju/gravity:v0.34.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/BeryJu/gravity/blob/38c7947343d673dbe379ba3cc412fabf773ff7d9/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/BeryJu/gravity)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Go DHCP, DNS and web server for the network, so it needs host networking and privileged ports 53 and 67 with root-level network access. Upstream publishes only gravity-cli binaries, so the server must be compiled from Go source for each arch.

### amd64 / arm64

How we get the application for that architecture.

- `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.

- **amd64**: compile
- **arm64**: compile

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/beryju/gravity:v0.34.0](https://ghcr.io/beryju/gravity)
- **copy-from arm64**: [ghcr.io/beryju/gravity:v0.34.0](https://ghcr.io/beryju/gravity)

### Dependency containers

- **Dependency containers**: none
