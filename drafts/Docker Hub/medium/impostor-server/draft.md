# impostor-server

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: impostor-server
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/impostor-server
- **Source repository**: https://github.com/AeonLucid/Impostor

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/aeonlucid/impostor

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: .NET app with no language base, so the .NET runtime is added on ubuntu per the default rule.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: dotnet runtime 10.0 (inferred, unless release bundle is self-contained)
- python/pip: none
- node/npm: none
- other: Impostor-Server release tarball (linux-x64 / linux-arm64)

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: impostor-server
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/aeonlucid/impostor:nightly, v1.10.10`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/AeonLucid/Impostor/blob/v1.10.10/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/AeonLucid/Impostor)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/AeonLucid/Impostor/releases/download/v1.10.10/Impostor-Server_1.10.10_linux-x64.tar.gz) · [arm64](https://github.com/AeonLucid/Impostor/releases/download/v1.10.10/Impostor-Server_1.10.10_linux-arm64.tar.gz)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: .NET 10 game server built with dotnet publish. ContainerForge has no .NET app, so the .NET runtime must be added on containerforge-ubuntu unless the release bundle is self-contained. It is one process on a UDP port, with config in /config.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [aeonlucid/impostor:nightly](https://hub.docker.com/r/aeonlucid/impostor)
- **copy-from arm64**: [aeonlucid/impostor:nightly](https://hub.docker.com/r/aeonlucid/impostor)

### Dependency containers

- **Dependency containers**: none
