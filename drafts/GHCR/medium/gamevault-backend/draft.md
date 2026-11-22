# gamevault-backend

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: medium
- **Chart**: gamevault-backend
- **Rows**: 1
- **Hard dependency containers**: yes (postgresql)
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/gamevault-backend
- **Source repository**: https://github.com/Phalcode/gamevault-backend

## Potentially relevant resources

- **Container image**: https://ghcr.io/phalcode/gamevault-backend

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: `ghcr.io/trueforge-org/python-node`
- **Reason**: TypeScript/Node server that the draft says runs on the node sibling.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: pnpm build deps, TypeScript server (inferred)
- other: pnpm

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8080/http (API and web UI)

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: gamevault-backend
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/phalcode/gamevault-backend:17.2.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/Phalcode/gamevault-backend/blob/17.2.0/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/Phalcode/gamevault-backend)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/Phalcode/gamevault-backend/releases/tag/17.2.0)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: GameVault backend is a TypeScript/Node server built with pnpm in a build stage and run on the node sibling. It is one process that needs a PostgreSQL database (PostgreSQL in the chart) and writable upload storage that must move to /config. The build step is the main effort.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/phalcode/gamevault-backend:17.2.0](https://ghcr.io/phalcode/gamevault-backend)
- **copy-from arm64**: [ghcr.io/phalcode/gamevault-backend:17.2.0](https://ghcr.io/phalcode/gamevault-backend)

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

- **Dependency containers**: postgresql ✅
