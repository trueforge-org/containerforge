# baserow

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: baserow
- **Rows**: 1
- **Hard dependency containers**: yes (postgresql, valkey)
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/baserow
- **Source repository**: https://github.com/baserow/baserow
- **Documentation**: https://baserow.io/docs/index

## Potentially relevant resources

- **Source code repository**: https://gitlab.com/bramw/baserow
- **Container image**: https://hub.docker.com/r/baserow/baserow

## Base container

- **Foundation**: ubuntu (`ghcr.io/trueforge-org/ubuntu:26.4`), which every ContainerForge runtime image is built on
- **Runtime image**: python
- **Alternative runtime image**: python-node
- **Reason**: Django backend is the main runtime, with a Node frontend build.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: baserow
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/baserow/baserow:2.4.3`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/baserow/baserow/blob/d897b90e9b819d4cde8b8c542f548bcdc21cd97f/deploy/all-in-one/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/baserow/baserow)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/baserow/baserow/releases/tag/2.4.3)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: All-in-one image running a Django backend, a web frontend, Caddy and supervisord-managed workers in one container. It is a multi-service stack that needs PostgreSQL postgres and valkey siblings and rootless rework for Caddy and supervisor. The code is arch-neutral Python and JS.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [baserow/baserow:2.4.3](https://hub.docker.com/r/baserow/baserow)
- **copy-from arm64**: [baserow/baserow:2.4.3](https://hub.docker.com/r/baserow/baserow)

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

- **Dependency containers**: valkey ✅, postgresql ✅
