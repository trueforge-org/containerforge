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
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/minecraft-bedrock
- **Website**: https://www.minecraft.net/en-us/download/server/bedrock
- **Documentation**: https://learn.microsoft.com/en-us/minecraft/creator/documents/bedrockserver/getting-started

## Potentially relevant resources

- **Container image**: https://ghcr.io/itzg/minecraft-bedrock-server
- **Source code repository**: https://github.com/itzg/docker-minecraft-server

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Native x86_64 server binary with no Java or Node runtime.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: box64 (arm64 only, explicit), unzip (inferred)
- python/pip: none
- node/npm: none
- other: Mojang bedrock server zip (amd64 only, download at build or start); itzg set-property and entrypoint-demoter release binaries

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 19132/udp (game)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/minecraft-bedrock
- non-root: possible - runAsUser 568 default, no override; draft mentions itzg entrypoint-demoter, which may expect a root start
- read-only-rootfs: yes - default true, not overridden; server data is on the /data mount
- privileged: no - default false, not overridden
- other-security: none
- extra-persistence: /data (pvc, server data and worlds). Draft says /config, the chart uses /data.
- confidence: low

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: the operator must accept the Mojang EULA, which is a licensing requirement (licensing).
- caveat: the server is x86_64 only; arm64 needs box64 emulation, which the draft does not cover, so treat it as amd64-only (architecture).
- caveat: the server zip is downloaded from Mojang at start or build, so the first start needs internet and the URL can change (runtime download).

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
