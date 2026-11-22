# teslamate

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: teslamate
- **Rows**: 1
- **Hard dependency containers**: yes (postgresql)
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/teslamate
- **Source repository**: https://github.com/teslamate-org/teslamate
- **Documentation**: https://docs.teslamate.org/

## Potentially relevant resources

- **Website**: https://docs.teslamate.org/docs/installation/docker
- **Container image**: https://hub.docker.com/r/teslamate/teslamate

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Elixir release is not provided by any base, so ubuntu is used with Node only at build time.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: elixir, erlang-dev, build-essential, git (inferred), nodejs, npm (build-time, inferred)
- python/pip: none
- node/npm: npm for asset build (inferred)
- other: Hex/rebar mix deps (inferred), teslamate v4.5.0 source build

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 4000/http (web UI)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/teslamate
- non-root: yes - no runAsUser override in values, so common default 568 applies
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - default false, no override
- other-security: none
- extra-persistence: none (external PostgreSQL via CNPG; grafana configmap only)
- confidence: medium

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

- **Reason**: Elixir release that needs an Erlang/Elixir toolchain ContainerForge does not have, plus an asset build with node. No release artifacts exist, so both architectures must compile from source. It uses an external PostgreSQL, which is a moderate dependency.

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

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

- **Dependency containers**: postgresql ✅
