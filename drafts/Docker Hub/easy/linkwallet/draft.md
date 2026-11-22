# linkwallet

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: easy
- **Chart**: linkwallet
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/linkwallet
- **Source repository**: https://github.com/tardisx/linkwallet

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/tardisx/linkwallet

## Base container

- **Foundation**: ubuntu (`ghcr.io/trueforge-org/ubuntu:26.4`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Prebuilt Go binary from the release tarball.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: linkwallet
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/tardisx/linkwallet:v0.1.1`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/tardisx/linkwallet/blob/59f70ae/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/tardisx/linkwallet)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/tardisx/linkwallet/releases/download/v0.1.1/linkwallet_Linux_x86_64.tar.gz) · [arm64](https://github.com/tardisx/linkwallet/releases/download/v0.1.1/linkwallet_Linux_arm64.tar.gz)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Prebuilt Go binary shipped as a tarball for linux x86_64 and arm64, so the image is just the binary dropped into /app on containerforge-ubuntu. The default-branch Dockerfile uses alpine:3.16 only as a carrier. Single process with no extra services.

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
