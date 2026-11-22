# storj-node

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: easy
- **Chart**: storj-node
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/storj-node
- **Source repository**: https://github.com/storj/storj

## Potentially relevant resources

- **Website**: https://docs.storj.io/node
- **Container image**: https://hub.docker.com/r/storjlabs/storagenode

## Base container

- **Foundation**: ubuntu (`ghcr.io/trueforge-org/ubuntu:26.4`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Go storage node unpacked from the release zip.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: storj-node
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/storjlabs/storagenode:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/storj/storagenode-docker/blob/main/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/storj/storj)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/storj/storj/releases/download/v1.166.4/identity_linux_amd64.zip) · [arm64](https://github.com/storj/storj/releases/download/v1.166.4/identity_linux_arm64.zip)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Go storagenode shipped as a release zip for linux amd64 and arm64, so ContainerForge can unpack it into /app on containerforge-ubuntu with no compile. Identity and storage data live in /config. The chart runs as root today, so the port and identity permissions need a check. No extra services.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [storjlabs/storagenode:latest](https://hub.docker.com/r/storjlabs/storagenode)
- **copy-from arm64**: [storjlabs/storagenode:latest](https://hub.docker.com/r/storjlabs/storagenode)

### Dependency containers

- **Dependency containers**: none
