# recyclarr

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: easy
- **Chart**: recyclarr
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/recyclarr
- **Source repository**: https://github.com/recyclarr/recyclarr
- **Documentation**: https://recyclarr.dev/

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: recyclarr
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/recyclarr/recyclarr:8.8.1`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/recyclarr/recyclarr/blob/v8.8.1/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/recyclarr/recyclarr)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/recyclarr/recyclarr/releases/download/v8.8.1/recyclarr-linux-musl-x64.tar.xz) · [arm64](https://github.com/recyclarr/recyclarr/releases/download/v8.8.1/recyclarr-linux-arm64.tar.xz)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Recyclarr is a .NET CLI published as release tarballs for linux x64 and arm64. One process runs with its state in /config. Whether the tarball includes the .NET runtime needs confirming; if not, an apt .NET runtime is needed.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: no
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
