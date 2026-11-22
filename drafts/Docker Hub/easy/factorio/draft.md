# factorio

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: easy
- **Chart**: factorio
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/factorio
- **Website**: https://factorio.com/
- **Documentation**: https://wiki.factorio.com/

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: factorio
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/factoriotools/factorio:stable`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/factoriotools/factorio-docker/blob/446f2553eedb142eb6a25c670af7def2647ba24c/docker/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://factorio.com/)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://factorio.com/get-download/stable/headless/linux64)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Headless Factorio is a vendor tarball, checked by sha256 in the upstream image. Unpack into /app, run as a non-root user, and keep saves and config in /config, which may be empty at start. The game is closed source but freely downloadable, so it can be ported.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.
- `no`: neither works for that architecture, for example closed-source software where the vendor only ships an amd64 executable.

- **amd64**: yes
- **arm64**: no

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [factoriotools/factorio:stable](https://hub.docker.com/r/factoriotools/factorio)
- **copy-from arm64**: [factoriotools/factorio:stable](https://hub.docker.com/r/factoriotools/factorio)

### Dependency containers

- **Dependency containers**: none
