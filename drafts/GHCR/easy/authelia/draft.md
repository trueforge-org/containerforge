# authelia

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: easy
- **Chart**: authelia
- **Rows**: 1
- **Hard dependency containers**: yes (postgresql)
- **Optional dependency containers**: yes (valkey)
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/authelia
- **Source repository**: https://github.com/authelia/authelia
- **Documentation**: https://www.authelia.com/
- **Website**: https://www.authelia.com/

## Potentially relevant resources

- **Container image**: https://ghcr.io/authelia/authelia
- **Source code repository**: https://github.com/authelia/chartrepo

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: authelia
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/authelia/authelia:4.39.28`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/authelia/authelia/blob/8da42b2348b0351c6284a2940a9c5eec3d4cd3fd/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/authelia/authelia)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/authelia/authelia/releases/download/v4.39.28/authelia-v4.39.28-linux-amd64-musl.tar.gz) · [arm64](https://github.com/authelia/authelia/releases/download/v4.39.28/authelia-v4.39.28-linux-arm64-musl.tar.gz)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Go authentication server, and upstream publishes linux amd64 tarballs and arm64 debs, so ubuntu can reuse the release binary. Its database and valkey are external services here, so it runs as one process with config in /config.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/authelia/authelia:4.39.28](https://ghcr.io/authelia/authelia)
- **copy-from arm64**: [ghcr.io/authelia/authelia:4.39.28](https://ghcr.io/authelia/authelia)

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

- **Dependency containers**: valkey ✅, postgresql ✅
