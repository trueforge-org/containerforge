# terraria-tshock

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: medium
- **Chart**: terraria-tshock
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/terraria-tshock
- **Source repository**: https://github.com/Pryaxis/TShock
- **Documentation**: https://ikebukuro.tshock.co/
- **Documentation**: https://tshock.readme.io/docs/getting-started

## Potentially relevant resources

- **Container image**: https://ghcr.io/ich777/terrariaserver
- **Website**: https://tshock.co

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: .NET 9 server run with the dotnet runtime from apt.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: dotnet-runtime-9.0 (inferred package name), unzip (inferred)
- python/pip: none
- node/npm: none
- other: TShock 6.2.1 release zip download (amd64 and arm64)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 7777/tcp (game server), 7878/http (TShock REST API, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/terraria-tshock
- non-root: no - container override runAsUser 0, runAsGroup 0
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - not set, common default false
- other-security: none
- extra-persistence: none beyond chart's own serverfiles
- confidence: high

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: The Terraria client version must match the TShock build (TShock 6.2.1 for Terraria 1.4.5.8), so players on a different version cannot join (from the draft).
- caveat: The first start asks for world creation and TShock admin setup, which is a manual step through the console or the in-game login (inferred).
- caveat: The .NET runtime package name in apt is inferred and must be checked for Ubuntu (inferred).

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
