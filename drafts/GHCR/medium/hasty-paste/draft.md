# hasty-paste

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: medium
- **Chart**: hasty-paste
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/hasty-paste
- **Source repository**: https://github.com/enchant97/hasty-paste

## Potentially relevant resources

- **Container image**: https://ghcr.io/enchant97/hasty-paste
- **Source code repository**: https://github.com/enchant97/hasty-paste/blob/main/docs/install.md

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Go backend is the runtime process; the node frontend is built in a builder stage.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: web frontend build deps (inferred)
- other: Go modules for the Go backend

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8000/http (web UI and API) (inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/hasty-paste
- non-root: yes - common default runAsUser 568, no root override
- read-only-rootfs: yes - common default true; data is a pvc mount
- privileged: no - common default false, no override
- other-security: none
- extra-persistence: none beyond the chart's /opt/hasty-paste/data pvc (draft keeps uploads under /config, so the path differs)
- confidence: medium

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: hasty-paste
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/enchant97/hasty-paste:2.5.1`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/enchant97/hasty-paste/blob/ad6a831789716dfdfde3a68e22ff5bb2ef1b0851/app/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/enchant97/hasty-paste)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Go backend plus a node-built web frontend; upstream copies both into a distroless static image. On containerforge-ubuntu we build the Go binary and frontend in a builder stage, copy them into /app and keep uploads under /config. One process and no database is required, so the work is a modest two-language build.

### amd64 / arm64

How we get the application for that architecture.

- `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.

- **amd64**: compile
- **arm64**: compile

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/enchant97/hasty-paste:2.5.1](https://ghcr.io/enchant97/hasty-paste)
- **copy-from arm64**: [ghcr.io/enchant97/hasty-paste:2.5.1](https://ghcr.io/enchant97/hasty-paste)

### Dependency containers

- **Dependency containers**: none
