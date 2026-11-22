# plex-playlist-sync

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: easy
- **Chart**: plex-playlist-sync
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/plex-playlist-sync
- **Source repository**: https://github.com/rnagabhyrava/plex-playlist-sync

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/rnagabhyrava/plexplaylistsync

## Base container

- **Primary**: python
- **Alternative**: none
- **Reason**: Python script installed from requirements with pip.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: plex-playlist-sync
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/rnagabhyrava/plexplaylistsync:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/rnagabhyrava/plex-playlist-sync/blob/c3333a506066c1294f67f297681fd2c342b4e2ff/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/rnagabhyrava/plex-playlist-sync)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/rnagabhyrava/plex-playlist-sync/releases/tag/v1.0.2)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Python script installed from requirements with pip into /app on a python base, with no extra services. Reuse the python sibling and keep the sync state under /config. Needs plex reachable over the network.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: no
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
