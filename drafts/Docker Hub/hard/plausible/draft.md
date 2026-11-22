# plausible

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: plausible
- **Rows**: 1
- **Hard dependency containers**: yes (postgresql, clickhouse)
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/plausible
- **Source repository**: https://github.com/plausible/analytics
- **Documentation**: https://plausible.io/docs
- **Website**: https://plausible.io/

## Potentially relevant resources

- **Source code repository**: https://github.com/plausible/hosting
- **Container image**: https://hub.docker.com/r/plausible/analytics
- **Website**: https://plausible.io/docs/self-hosting

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Elixir is not provided by any base, so ubuntu is used with Elixir added to the build.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: elixir (inferred), erlang-dev (inferred)
- python/pip: none
- node/npm: nodejs (inferred, asset build)
- other: Elixir/Phoenix mix release build, ClickHouse as separate service

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8000/http (web UI and API)

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: plausible
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/plausible/analytics:v2.0.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/plausible/analytics/blob/0621fc0a77cc50add00baddbdd59f378324da483/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/plausible/analytics)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Elixir/Phoenix app built with mix release, a toolchain ContainerForge does not ship. It also needs ClickHouse as a separate service plus PostgreSQL, so the chart is a multi-service stack. Upstream publishes images only, not standalone release binaries.

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

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

- **Dependency containers**: clickhouse ✅, postgresql ✅
