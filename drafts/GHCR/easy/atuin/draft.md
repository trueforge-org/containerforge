# atuin

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: easy
- **Chart**: atuin
- **Rows**: 1
- **Hard dependency containers**: yes (postgresql)
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/atuin
- **Source repository**: https://github.com/atuinsh/atuin
- **Documentation**: https://docs.atuin.sh/

## Potentially relevant resources

- **Container image**: https://ghcr.io/atuinsh/atuin

## Base container

- **Primary**: ubuntu
- **Alternative**: none
- **Reason**: Rust server release binary run directly on ubuntu.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: atuin
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/atuinsh/atuin:18.25.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/atuinsh/atuin/blob/d154a94090a7e390c1685c10252128545cdcacbd/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/atuinsh/atuin)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/atuinsh/atuin/releases/download/v18.25.0/atuin-server-x86_64-unknown-linux-gnu.tar.gz) · [arm64](https://github.com/atuinsh/atuin/releases/download/v18.25.0/atuin-aarch64-unknown-linux-gnu.tar.gz)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Rust atuin-server binary, and upstream publishes linux server tarballs, so ubuntu can install the release binary with no compile. It is a single process, and the PostgreSQL database is the external PostgreSQL cluster here.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/atuinsh/atuin:18.25.0](https://ghcr.io/atuinsh/atuin)
- **copy-from arm64**: [ghcr.io/atuinsh/atuin:18.25.0](https://ghcr.io/atuinsh/atuin)

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

- **Dependency containers**: postgresql ✅
