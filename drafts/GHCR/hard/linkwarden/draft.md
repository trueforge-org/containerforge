# linkwarden

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: hard
- **Chart**: linkwarden
- **Rows**: 1
- **Hard dependency containers**: yes (postgresql)
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/linkwarden
- **Source repository**: https://github.com/linkwarden/linkwarden
- **Documentation**: https://docs.linkwarden.app/
- **Website**: https://linkwarden.app/

## Potentially relevant resources

- **Container image**: https://ghcr.io/linkwarden/linkwarden

## Base container

- **Primary**: python-node
- **Alternative**: none
- **Reason**: Next.js Node.js monorepo is the main runtime; the Rust binary is an extra piece.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: linkwarden
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/linkwarden/linkwarden:v2.17.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/linkwarden/linkwarden/blob/v2.17.0/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/linkwarden/linkwarden)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Yarn monorepo Next.js app plus a Rust monolith binary built with cargo, needing Postgres via PostgreSQL and Prisma migrations at start. Several toolchains, a database and a large stack make it hard. The image is rootful in the source Dockerfile.

### amd64 / arm64

How we get the application for that architecture.

- `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.

- **amd64**: compile
- **arm64**: compile

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/linkwarden/linkwarden:v2.17.0](https://ghcr.io/linkwarden/linkwarden)
- **copy-from arm64**: [ghcr.io/linkwarden/linkwarden:v2.17.0](https://ghcr.io/linkwarden/linkwarden)

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

- **Dependency containers**: postgresql ✅
