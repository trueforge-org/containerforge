# teslamate

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: teslamate
- **Rows**: 1
- **Hard dependency containers**: yes (postgresql (CNPG))
- **Soft dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **Source repository**: https://github.com/teslamate-org/teslamate
- **Documentation**: https://docs.teslamate.org/

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: teslamate
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/teslamate/teslamate:4.5.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/teslamate-org/teslamate/blob/v4.5.0/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/teslamate-org/teslamate)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Elixir release that needs an Erlang/Elixir toolchain ContainerForge does not have, plus an asset build with node. No release artifacts exist, so both architectures must compile from source. It uses an external PostgreSQL (CNPG), which is a moderate dependency.

### amd64 / arm64

How we get the application for that architecture.

- `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.

- **amd64**: compile
- **arm64**: compile

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [teslamate/teslamate:4.5.0](https://hub.docker.com/r/teslamate/teslamate)
- **copy-from arm64**: [teslamate/teslamate:4.5.0](https://hub.docker.com/r/teslamate/teslamate)

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, CNPG PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

- **Dependency containers**: postgresql (CNPG) ✅
