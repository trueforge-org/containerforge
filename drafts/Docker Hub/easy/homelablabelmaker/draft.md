# homelablabelmaker

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: easy
- **Chart**: homelablabelmaker
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/homelablabelmaker
- **Source repository**: https://github.com/DavidSpek/homelablabelmaker
- **Website**: https://homelablabelmaker.shurilla14.com/

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/davidspek/homelablabelmaker

## Base container

- **Primary**: nginx
- **Alternative**: ubuntu
- **Reason**: Static label-maker files served by nginx.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: homelablabelmaker
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/davidspek/homelablabelmaker:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/DavidSpek/homelablabelmaker/blob/d52776c7bd405bf388f53a725a640f2c1a461ae4/Docker%20Files/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/DavidSpek/homelablabelmaker)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/DavidSpek/homelablabelmaker/archive/d52776c7bd405bf388f53a725a640f2c1a461ae4.zip)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Static label-maker web app served from httpd:alpine, with a git clone of the repo at build time. Copy the static files into /app and serve with the nginx sibling; replace the build-time git clone with a plain source copy.

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
