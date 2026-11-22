# calendarr

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: easy
- **Chart**: calendarr
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/calendarr
- **Source repository**: https://github.com/jordanlambrecht/calendarr

## Potentially relevant resources

- **Container image**: https://ghcr.io/jordanlambrecht/calendarr

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: calendarr
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/jordanlambrecht/calendarr:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/jordanlambrecht/calendarr/blob/4da458fb9d59a787c6ae1819eb063ba91cfe83d1/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/jordanlambrecht/calendarr)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/jordanlambrecht/calendarr/releases/tag/v1.5.2)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Python web app installed from requirements.txt on python:3.15 slim, with source copied in. Reuse the python sibling with pip into /app or a venv in /tmp, keep the database in /config, and run without extra services. Easy.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/jordanlambrecht/calendarr:latest](https://ghcr.io/jordanlambrecht/calendarr)
- **copy-from arm64**: [ghcr.io/jordanlambrecht/calendarr:latest](https://ghcr.io/jordanlambrecht/calendarr)

### Dependency containers

- **Dependency containers**: none
