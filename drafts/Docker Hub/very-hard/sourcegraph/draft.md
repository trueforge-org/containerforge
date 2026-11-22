# sourcegraph

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: very-hard
- **Chart**: sourcegraph
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/sourcegraph
- **Source repository**: https://github.com/sourcegraph/sourcegraph
- **Documentation**: https://sourcegraph.com/docs

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/sourcegraph/server

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Guess: no public Dockerfile or binaries exist, so no runtime is clearly needed and ubuntu is a default.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: none
- other: none

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: sourcegraph
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/sourcegraph/server:6.12.5040`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

`-` means no public Dockerfile could be found.

- **Dockerfile**: -

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/sourcegraph/sourcegraph)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`very-hard`: closed source with no redistributable artifact, or kernel/host-level tools.

- **Difficulty**: very-hard

### Reason

- **Reason**: Sourcegraph 6.x is a large multi-service monolith (frontend, gitserver, searcher, Postgres, Redis) and the code is no longer open source. No public Dockerfile or standalone binaries are available, only Docker images, so it cannot realistically be rebuilt on containerforge-ubuntu.

### amd64 / arm64

How we get the application for that architecture.

- `no`: neither works for that architecture, for example closed-source software where the vendor only ships an amd64 executable.

- **amd64**: no
- **arm64**: no

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [sourcegraph/server:6.12.5040](https://hub.docker.com/r/sourcegraph/server)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
