# vintage-story

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: hard
- **Chart**: vintage-story
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/vintage-story
- **Website**: https://www.vintagestory.at/
- **Documentation**: https://wiki.vintagestory.at/index.php/Server_Config

## Potentially relevant resources

- **Container image**: https://ghcr.io/ich777/vintagestory

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: .NET game server with the dotnet runtime installed on ubuntu.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: dotnet-runtime-10.0 (inferred)
- python/pip: none
- node/npm: none
- other: Vintage Story server tarball from vintagestory.at (x64 only)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 42420/tcp (game, inferred), 42420/udp (game, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/vintage-story
- non-root: no - runAsUser 0, runAsGroup 0
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - not set, common default false
- other-security: none
- extra-persistence: /vintagestory (chart path, type not set)
- confidence: high

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: vintage-story
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/ich777/vintagestory:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/ich777/docker-vintage-story/blob/master/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://www.vintagestory.at/)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://www.vintagestory.at/)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Closed-source .NET game server tarball fetched from vintagestory.at at runtime; the ich777 image adds dotnet-runtime-10.0 on a mono base. On containerforge-ubuntu install the dotnet runtime, unpack to /app, keep data in /config. Vendor ships x64 only, root and runtime download need rework.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.
- `no`: neither works for that architecture, for example closed-source software where the vendor only ships an amd64 executable.

- **amd64**: yes
- **arm64**: no

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [ghcr.io/ich777/vintagestory:latest](https://ghcr.io/ich777/vintagestory)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
