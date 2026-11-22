# ghostfolio

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: ghostfolio
- **Rows**: 1
- **Hard dependency containers**: yes (postgresql (CNPG), valkey)
- **Soft dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **Source repository**: https://github.com/ghostfolio/ghostfolio
- **Website**: https://ghostfol.io

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: ghostfolio
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/ghostfolio/ghostfolio:3.100.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/ghostfolio/ghostfolio/blob/45d692301c1e9c0dca5bcc77cb06a9e408af019c/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/ghostfolio/ghostfolio)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/ghostfolio/ghostfolio/releases/tag/3.100.0)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Large Nx monorepo with an Angular frontend and Nest backend, built in a node stage. Needs prisma migrations plus postgres (cnpg) and valkey, so it is several services in one stack. Heavy build and runtime moving parts.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghostfolio/ghostfolio:3.100.0](https://hub.docker.com/r/ghostfolio/ghostfolio)
- **copy-from arm64**: [ghostfolio/ghostfolio:3.100.0](https://hub.docker.com/r/ghostfolio/ghostfolio)

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, CNPG PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

- **Dependency containers**: valkey ✅, postgresql (CNPG) ✅
