# invitarr

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: easy
- **Chart**: invitarr
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/invitarr
- **Source repository**: https://github.com/Sleepingpirates/Invitarr

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/piratify/invitarr

## Base container

- **Primary**: python
- **Alternative**: none
- **Reason**: Python Discord bot installed with pip from requirements.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: invitarr
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/piratify/invitarr:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/Sleepingpirates/Invitarr/blob/ce30f130dac51352fd5a1336c87c30cece79f085/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/Sleepingpirates/Invitarr)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/Sleepingpirates/Invitarr/archive/ce30f130dac51352fd5a1336c87c30cece79f085.zip)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Python Discord bot installed with pip from requirements into /app on a python base, with no extra services. Reuse the python sibling and run as apps user with state under /config. Only the bot process is needed.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [piratify/invitarr:latest](https://hub.docker.com/r/piratify/invitarr)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
