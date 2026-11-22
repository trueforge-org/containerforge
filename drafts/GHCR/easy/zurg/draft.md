# zurg

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: easy
- **Chart**: zurg
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/zurg
- **Source repository**: https://github.com/debridmediamanager/zurg-public
- **Documentation**: https://github.com/debridmediamanager/zurg-public/wiki

## Potentially relevant resources

- **Container image**: https://ghcr.io/geek-cookbook/zurg

## Base container

- **Foundation**: ubuntu (`ghcr.io/trueforge-org/ubuntu:26.4`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Static Go binary in a linux zip.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: zurg
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/geek-cookbook/zurg:v0.9.3-hotfix.11`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/geek-cookbook/containers/blob/69a4d32bdba580ccb4e6578ea4e95507d55684b3/apps/zurg/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/debridmediamanager/zurg-public)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/debridmediamanager/zurg-public/releases/download/v0.9.3-hotfix.11/zurg-v0.9.3-hotfix.11-linux-amd64.zip) · [arm64](https://github.com/debridmediamanager/zurg-public/releases/download/v0.9.3-hotfix.11/zurg-v0.9.3-hotfix.11-linux-arm64.zip)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Closed-source but redistributable Go binary from the zurg-public release, copied into an alpine wrapper image. Download the linux zip on containerforge-ubuntu, run it as one process with config under /config; glibc is fine for the static binary.

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
