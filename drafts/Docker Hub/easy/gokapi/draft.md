# gokapi

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: easy
- **Chart**: gokapi
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/gokapi
- **Source repository**: https://github.com/Forceu/gokapi
- **Documentation**: https://gokapi.readthedocs.io/en/latest/

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/f0rc3/gokapi

## Base container

- **Foundation**: ubuntu (`ghcr.io/trueforge-org/ubuntu:26.4`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Single Go binary from the release zip.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: gokapi
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/f0rc3/gokapi:v2.2.4`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/Forceu/gokapi/blob/9a4b289c604198c05589e34314e889d2c25386d8/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/Forceu/gokapi)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/Forceu/Gokapi/releases/download/v2.2.4/gokapi-2.2.4_linux-amd64.zip) · [arm64](https://github.com/Forceu/Gokapi/releases/download/v2.2.4/gokapi-2.2.4_linux-arm64.zip)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Single Go binary shipped as a release zip per arch, so copy it into /app on containerforge-ubuntu with a non-root user. Data and config go to /config and temp files to /tmp. No services or build step needed.

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
