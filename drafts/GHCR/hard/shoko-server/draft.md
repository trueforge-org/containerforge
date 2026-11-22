# shoko-server

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: hard
- **Chart**: shoko-server
- **Rows**: 1
- **Hard dependency containers**: no
- **Soft dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **Source repository**: https://github.com/ShokoAnime/ShokoServer
- **Documentation**: https://docs.shokoanime.com/

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: shoko-server
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/shokoanime/server:v5.3.3`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/ShokoAnime/ShokoServer/blob/v5.3.3/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/ShokoAnime/ShokoServer)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/ShokoAnime/ShokoServer/releases/download/v5.3.3/Shoko.CLI_Framework_any-x64.zip)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Shoko Server is a .NET 8 app; the release ships a framework-dependent x64 CLI zip, while arm64 needs a dotnet publish from source. .NET is not an existing ContainerForge runtime, so it needs the dotnet runtime installed on containerforge-ubuntu, with media, plugin and data paths moved to /config for rootless read-only use.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.
- `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.

- **amd64**: yes
- **arm64**: compile

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/shokoanime/server:v5.3.3](https://ghcr.io/shokoanime/server)
- **copy-from arm64**: [ghcr.io/shokoanime/server:v5.3.3](https://ghcr.io/shokoanime/server)

### Dependency containers

- **Dependency containers**: none
