# godaddy-ddns

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: easy
- **Chart**: godaddy-ddns
- **Rows**: 1
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: godaddy-ddns
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/jwater7/godaddy-publicip-updater:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/jwater7/docker-godaddy-publicip-updater/blob/ab3b048/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/jwater7/docker-godaddy-publicip-updater)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/jwater7/docker-godaddy-publicip-updater/releases/tag/releases/1.0.4)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Small Python updater that pip installs godaddypy and pif and runs one script. It needs no services, only outbound HTTPS and a config under /config. On the python sibling this is a single pip install into /app with no compile.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [jwater7/godaddy-publicip-updater:latest](https://hub.docker.com/r/jwater7/godaddy-publicip-updater)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
