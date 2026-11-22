# picoshare

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: easy
- **Chart**: picoshare
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/picoshare
- **Source repository**: https://github.com/mtlynch/picoshare

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/mtlynch/picoshare

## Base container

- **Primary**: ubuntu
- **Alternative**: none
- **Reason**: Go binary from the release tarball.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: picoshare
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/mtlynch/picoshare:v1.5.5`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/mtlynch/picoshare/blob/v1.5.5/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/mtlynch/picoshare)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/mtlynch/picoshare/releases/download/v1.5.5/picoshare-v1.5.5-linux-amd64.tar.gz) · [arm64](https://github.com/mtlynch/picoshare/releases/download/v1.5.5/picoshare-v1.5.5-linux-arm64.tar.gz)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Go binary with litestream for SQLite replication, so the release tarball gives the server directly and litestream is an extra static binary. Run it as apps with the data in /config and no other services.

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
