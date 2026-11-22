# tachidesk-docker

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: easy
- **Chart**: tachidesk-docker
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/tachidesk-docker
- **Source repository**: https://github.com/Suwayomi/Suwayomi-Server
- **Documentation**: https://github.com/Suwayomi/Suwayomi-Server/wiki/Configuring-Tachidesk-Server
- **Documentation**: https://github.com/Suwayomi/Suwayomi-Server/wiki
- **Website**: https://suwayomi.org/

## Potentially relevant resources

- **Container image**: https://ghcr.io/suwayomi/tachidesk
- **Source code repository**: https://github.com/Suwayomi/Tachidesk-Server
- **Source code repository**: https://github.com/suwayomi/docker-tachidesk

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [java21](https://github.com/trueforge-org/containerforge/tree/main/apps/java21) (`ghcr.io/trueforge-org/java21`)
- **Reason**: Java server JAR that the draft says runs on the java21 sibling.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: none
- other: Suwayomi server JAR (java21 sibling runtime)

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: tachidesk-docker
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/suwayomi/tachidesk:preview`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/suwayomi/docker-tachidesk/blob/7a2bdee0b5aab381f80a9186ef8c73507771050f/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/Suwayomi/Suwayomi-Server)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/Suwayomi/Suwayomi-Server/releases/download/v2.4.2366/Suwayomi-Server-v2.4.2366-linux-x64.tar.gz) · [arm64](https://github.com/Suwayomi/Suwayomi-Server/releases/download/v2.4.2366/Suwayomi-Server-v2.4.2366.jar)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Suwayomi Tachidesk is a Java server distributed as an arch-neutral JAR, so the release JAR runs on the java21 sibling as one process. Data and the downloaded WebUI go under /config and /tmp. The Dockerfile's JRE base is replaced by the sibling.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/suwayomi/tachidesk:preview](https://ghcr.io/suwayomi/tachidesk)
- **copy-from arm64**: [ghcr.io/suwayomi/tachidesk:preview](https://ghcr.io/suwayomi/tachidesk)

### Dependency containers

- **Dependency containers**: none
