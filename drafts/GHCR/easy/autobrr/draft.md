# autobrr

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: easy
- **Chart**: autobrr
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/autobrr
- **Source repository**: https://github.com/autobrr/autobrr
- **Documentation**: https://autobrr.com/introduction
- **Website**: https://autobrr.com

## Potentially relevant resources

- **Container image**: https://ghcr.io/autobrr/autobrr

## Base container

- **Foundation**: ubuntu (`ghcr.io/trueforge-org/ubuntu:26.4`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Go binary with embedded UI, run directly on ubuntu.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: autobrr
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/autobrr/autobrr:v1.91.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/autobrr/autobrr/blob/abad209f1e6a7041f27eadccc27a5468d1c555fc/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/autobrr/autobrr)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/autobrr/autobrr/releases/download/v1.91.0/autobrr_1.91.0_linux_amd64.apk) · [arm64](https://github.com/autobrr/autobrr/releases/download/v1.91.0/autobrr_1.91.0_linux_arm64.apk)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Go binary with embedded web UI, and upstream ships per-arch Linux tarballs, so ubuntu can install the release binary with no compile. It runs as one process with data in /config and no bundled services.

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
