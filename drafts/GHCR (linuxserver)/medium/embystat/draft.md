# embystat

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR (linuxserver)
- **Difficulty**: medium
- **Chart**: embystat
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/embystat
- **Source repository**: https://github.com/mregni/EmbyStat

## Potentially relevant resources

- **Container image**: https://ghcr.io/linuxserver/embystat

## Base container

- **Foundation**: ubuntu (`ghcr.io/trueforge-org/ubuntu:26.4`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: ASP.NET app shipped as a self-contained release zip, which the ubuntu base can run.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: embystat
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/linuxserver/embystat:0.2.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/linuxserver/docker-embystat/blob/5fa06c158344aeefbec98e0e211b34198f4f2063/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/mregni/EmbyStat)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/mregni/EmbyStat/releases/download/0.2.0-beta.30/EmbyStat-debian-x64-v0.2.0-beta.30.zip) · [arm64](https://github.com/mregni/EmbyStat/releases/download/0.2.0-beta.30/EmbyStat-linux-arm-x64-v0.2.0-beta.30.zip)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: ASP.NET (.NET) web app shipped as per-platform release zips. Unpack the linux x64 or 64-bit ARM zip into /app on containerforge-ubuntu, keep the bundled runtime if the zip is self-contained, and store the database in /config. Single process, no extra services.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/linuxserver/embystat:0.2.0](https://ghcr.io/linuxserver/embystat)
- **copy-from arm64**: [ghcr.io/linuxserver/embystat:0.2.0](https://ghcr.io/linuxserver/embystat)

### Dependency containers

- **Dependency containers**: none
