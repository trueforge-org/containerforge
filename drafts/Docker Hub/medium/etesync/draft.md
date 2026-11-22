# etesync

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: etesync
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: yes (postgresql, valkey)
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/etesync
- **Source repository**: https://github.com/etesync/server

## Potentially relevant resources

- **Source code repository**: https://github.com/etesync
- **Source code repository**: https://github.com/victor-rds/docker-etebase
- **Container image**: https://hub.docker.com/r/victorrds/etesync
- **Website**: https://www.etesync.com

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [python](https://github.com/trueforge-org/containerforge/tree/main/apps/python) (`ghcr.io/trueforge-org/python`)
- **Reason**: Python server installed by pip, so python fits.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: etesync
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/victorrds/etesync:0.14.2`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/victor-rds/docker-etebase/blob/c06eb631/tags/base/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/etesync/server)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/etesync/server/releases)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Python EteSync server, installed by pip from the etesync/server source with its requirements, and it uses a Valkey and PostgreSQL dependency. It fits the python sibling, but the Django/uwsgi setup needs wiring to /config and /tmp. Wheels cover both architectures.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [victorrds/etesync:0.14.2](https://hub.docker.com/r/victorrds/etesync)
- **copy-from arm64**: [victorrds/etesync:0.14.2](https://hub.docker.com/r/victorrds/etesync)

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

- **Dependency containers**: valkey ✅, postgresql ✅
