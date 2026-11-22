# minecraft-bedrock

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: medium
- **Chart**: minecraft-bedrock
- **Rows**: 1
- **Hard dependency containers**: no
- **Soft dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **Website**: https://www.minecraft.net/en-us/download/server/bedrock
- **Documentation**: https://learn.microsoft.com/en-us/minecraft/creator/documents/bedrockserver/getting-started

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: minecraft-bedrock
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/itzg/minecraft-bedrock-server:2026.11.1`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/itzg/docker-minecraft-bedrock-server/blob/dbf8516038c8/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://www.minecraft.net/en-us/download/server/bedrock)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://www.minecraft.net/en-us/download/server/bedrock)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Mojang closed-source x86_64 server zip downloaded at start or build; arm64 runs it through apt box64 (slower, emulated). Server dir and worlds must move to /config, and itzg helper tools (set-property, entrypoint-demoter) come from their releases.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.
- `no`: neither works for that architecture, for example closed-source software where the vendor only ships an amd64 executable.

- **amd64**: yes
- **arm64**: no

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/itzg/minecraft-bedrock-server:2026.11.1](https://ghcr.io/itzg/minecraft-bedrock-server)
- **copy-from arm64**: [ghcr.io/itzg/minecraft-bedrock-server:2026.11.1](https://ghcr.io/itzg/minecraft-bedrock-server)

### Dependency containers

- **Dependency containers**: none
