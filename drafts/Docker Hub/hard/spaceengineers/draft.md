# spaceengineers

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: spaceengineers
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/spaceengineers
- **Website**: https://www.spaceengineersgame.com/

## Potentially relevant resources

- **Source code repository**: https://github.com/Devidian/docker-spaceengineers
- **Container image**: https://hub.docker.com/r/devidian/spaceengineers

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [steamcmd](https://github.com/trueforge-org/containerforge/tree/main/apps/steamcmd) (`ghcr.io/trueforge-org/steamcmd`)
- **Alternative runtime image**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`)
- **Reason**: Dedicated game server downloaded with the Steam download tool, so steamcmd fits.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: spaceengineers
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/devidian/spaceengineers:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/Devidian/docker-spaceengineers/blob/26569e3284bd38fccbe60c0943e1bd8442193c23/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://www.spaceengineersgame.com/)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://developer.valvesoftware.com/wiki/SteamCMD)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Windows-only Space Engineers dedicated server fetched by SteamCMD and run under Wine plus winetricks, so the steamcmd sibling covers the download but a Wine runtime must be added. Game files go to /config; Wine prefix needs a writable HOME in /tmp or /config, and the Wine run path is heavy.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.
- `no`: neither works for that architecture, for example closed-source software where the vendor only ships an amd64 executable.

- **amd64**: yes
- **arm64**: no

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [devidian/spaceengineers:latest](https://hub.docker.com/r/devidian/spaceengineers)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
