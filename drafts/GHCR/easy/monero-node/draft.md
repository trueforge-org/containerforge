# monero-node

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: easy
- **Chart**: monero-node
- **Rows**: 1
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: monero-node
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/sethforprivacy/simple-monerod:v0.18.5.4`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/sethforprivacy/simple-monerod-docker/blob/08e993d/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/monero-project/monero)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://downloads.getmonero.org/cli/monero-linux-x64-v0.18.5.4.tar.bz2) · [arm64](https://downloads.getmonero.org/cli/monero-linux-armv8-v0.18.5.4.tar.bz2)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: simple-monerod wraps the upstream monerod daemon, which is a single process shipped as official linux x64 and armv8 tarballs. The image needs a large writable chain volume under /config and nothing else. The Dockerfile's source build can be replaced by the release tarball.

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
