# peppermint

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: peppermint
- **Rows**: 1
- **Hard dependency containers**: yes (postgresql)
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/peppermint
- **Source repository**: https://github.com/Peppermint-Lab/peppermint
- **Website**: https://peppermint.sh/

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/pepperlabs/peppermint

## Base container

- **Foundation**: ubuntu (`ghcr.io/trueforge-org/ubuntu:26.4`), which every ContainerForge runtime image is built on
- **Runtime image**: python-node
- **Reason**: Node API and client build, so python-node provides node.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: peppermint
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/pepperlabs/peppermint:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/Peppermint-Lab/peppermint/blob/ba6e2179f9409db76abeb9a3007a262160e24628/dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/Peppermint-Lab/peppermint)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/Peppermint-Lab/peppermint/releases/tag/0.5.5)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Node build of the API and the client, with Prisma migrations and a Postgres dependency, copied into a node runner. The node sibling covers the runtime. The build is a few moving parts, and Prisma engines are fetched per arch at build time.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [pepperlabs/peppermint:latest](https://hub.docker.com/r/pepperlabs/peppermint)
- **copy-from arm64**: [pepperlabs/peppermint:latest](https://hub.docker.com/r/pepperlabs/peppermint)

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

- **Dependency containers**: postgresql ✅
