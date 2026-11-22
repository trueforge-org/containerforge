# affine

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: hard
- **Chart**: affine
- **Rows**: 1
- **Hard dependency containers**: yes (postgresql, valkey)
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/affine
- **Source repository**: https://github.com/toeverything/AFFiNE
- **Documentation**: https://docs.affine.pro/
- **Website**: https://affine.pro/

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: affine
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/toeverything/affine:0.27.4`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/toeverything/AFFiNE/blob/b4c8548c09da21b2898443559a5b846f0ccf5dd8/.github/deployment/node/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/toeverything/AFFiNE)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Node 22 yarn monorepo (server plus web frontend) that needs native Rust napi modules, with PostgreSQL and Valkey as required services. Upstream only ships a Docker image, so it must be built from source on node with a Rust toolchain; a large stack to port.

### amd64 / arm64

How we get the application for that architecture.

- `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.

- **amd64**: compile
- **arm64**: compile

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [ghcr.io/toeverything/affine:0.27.4](https://ghcr.io/toeverything/affine)
- **copy-from arm64**: no

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

- **Dependency containers**: valkey ✅, postgresql ✅
