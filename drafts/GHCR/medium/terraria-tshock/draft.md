# terraria-tshock

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: medium
- **Chart**: terraria-tshock
- **Rows**: 1
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **Source repository**: https://github.com/Pryaxis/TShock
- **Documentation**: https://ikebukuro.tshock.co/

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: terraria-tshock
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/ich777/terrariaserver:tshock`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/ich777/docker-terraria-server/blob/tshock/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/Pryaxis/TShock)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/Pryaxis/TShock/releases/download/v6.2.1/TShock-6.2.1-for-Terraria-1.4.5.8-linux-x64-Release.zip) · [arm64](https://github.com/Pryaxis/TShock/releases/download/v6.2.1/TShock-6.2.1-for-Terraria-1.4.5.8-linux-arm64-Release.zip)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: TShock 6 is a .NET 9 Terraria server mod shipped as a self-contained release zip; unpack into /app and run with the dotnet runtime from apt. Worlds and config go in /config; the ich777 root wrapper plus gotty must be replaced by a USER apps start script.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [ghcr.io/ich777/terrariaserver:tshock](https://ghcr.io/ich777/terrariaserver)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
