# sftpgo

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: easy
- **Chart**: sftpgo
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/sftpgo
- **Source repository**: https://github.com/drakkan/sftpgo
- **Documentation**: https://docs.sftpgo.com/latest/
- **Documentation**: https://docs.sftpgo.com/
- **Website**: https://sftpgo.com/

## Potentially relevant resources

- **Container image**: https://ghcr.io/drakkan/sftpgo

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Go binary from the upstream release.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: sftpgo
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/drakkan/sftpgo:v2.7.6-plugins`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/drakkan/sftpgo/blob/62ae9ba3957e9ed52b44a4f885e805e2d7b35972/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/drakkan/sftpgo)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/drakkan/sftpgo/releases/download/v2.7.6/sftpgo_2.7.6-1_amd64.deb) · [arm64](https://github.com/drakkan/sftpgo/releases/download/v2.7.6/sftpgo_2.7.6-1_arm64.deb)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Go binary; use the upstream release tarball on containerforge-ubuntu instead of the golang build stage. One process with SFTP and HTTP ports above 1024, data under /config. Plugin binaries (the -plugins tag) are optional extra downloads and can be skipped.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/drakkan/sftpgo:v2.7.6-plugins](https://ghcr.io/drakkan/sftpgo)
- **copy-from arm64**: [ghcr.io/drakkan/sftpgo:v2.7.6-plugins](https://ghcr.io/drakkan/sftpgo)

### Dependency containers

- **Dependency containers**: none
