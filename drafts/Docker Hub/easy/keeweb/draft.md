# keeweb

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: easy
- **Chart**: keeweb
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/keeweb
- **Source repository**: https://github.com/keeweb/keeweb

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/antelle/keeweb

## Base container

- **Primary**: nginx
- **Alternative**: ubuntu
- **Reason**: Static web app files served by nginx.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: keeweb
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/antelle/keeweb:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/keeweb/keeweb/blob/v1.18.7/package/docker/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/keeweb/keeweb)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/keeweb/keeweb/releases/download/v1.18.7/KeeWeb-1.18.7.linux.x64.deb) · [arm64](https://github.com/keeweb/keeweb/releases/download/v1.18.7/KeeWeb-1.18.7.win.arm64.zip)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Static web app that upstream builds with grunt and publishes as an html zip. Unpack the static files, serve them with the nginx sibling, and write nothing outside /tmp. No build stage is needed.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [antelle/keeweb:latest](https://hub.docker.com/r/antelle/keeweb)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
