# import-ics

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: easy
- **Chart**: import-ics
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/import-ics
- **Source repository**: https://github.com/Vilhjalmr26/import_ics

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/vilhjalmr26/import_ics

## Base container

- **Primary**: python
- **Alternative**: none
- **Reason**: Python web app installed with pip from requirements.txt.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: import-ics
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/vilhjalmr26/import_ics:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/Vilhjalmr26/import_ics/blob/ec04d6c/dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/Vilhjalmr26/import_ics)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/Vilhjalmr26/import_ics/archive/ec04d6c.zip)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Small Python web app installed with pip from requirements.txt on python:3.9 alpine. It is a single process with simple file I/O, so it runs on the python sibling with the app in /app. Pure Python dependencies need no compile.

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
