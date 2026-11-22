# urban-terror

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: medium
- **Chart**: urban-terror
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/urban-terror
- **Source repository**: https://github.com/FrozenSand/ioq3-for-UrbanTerror-4
- **Website**: https://www.urbanterror.info/home/

## Potentially relevant resources

- **Container image**: https://ghcr.io/ich777/urbanterror
- **Website**: https://www.urbanterror.info

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Native x86_64 dedicated server binary.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: urban-terror
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/ich777/urbanterror:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/ich777/docker-urbanterror/blob/master/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/FrozenSand/ioq3-for-UrbanTerror-4)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://www.urbanterror.info/downloads/software/urt/43/UrbanTerror43_ded.tar.gz)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Urban Terror dedicated server is the ioq3-based UrbanTerror43_ded.tar.gz with x86_64 binary, unpacked into /app (game data downloaded at start into /config). Needs a few apt libs and a USER apps start script replacing the root wrapper; no build step.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.
- `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.

- **amd64**: yes
- **arm64**: compile

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [ghcr.io/ich777/urbanterror:latest](https://ghcr.io/ich777/urbanterror)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
