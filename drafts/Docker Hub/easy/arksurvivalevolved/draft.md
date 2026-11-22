# arksurvivalevolved

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: easy
- **Chart**: arksurvivalevolved
- **Rows**: 1
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **Source repository**: https://github.com/arkmanager/ark-server-tools

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: arksurvivalevolved
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/drpsychick/arkserver:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/SickHub/arkserver/blob/394fd7aa4f6321e5665f9dbc7d1ff4600aa6386f/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/arkmanager/ark-server-tools)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: ARK server installed at runtime through arkmanager and SteamCMD, so it fits the ich777-style steamcmd game-server pattern and can reuse apps/steamcmd. Game files are large and go to /config; the ARK server binaries are x86_64 only.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.
- `no`: neither works for that architecture, for example closed-source software where the vendor only ships an amd64 executable.

- **amd64**: yes
- **arm64**: no

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [drpsychick/arkserver:latest](https://hub.docker.com/r/drpsychick/arkserver)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
