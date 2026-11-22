# glances

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: easy
- **Chart**: glances
- **Rows**: 1
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **Source repository**: https://github.com/nicolargo/glances

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: glances
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/nicolargo/glances:ubuntu-4.3.0.8-full`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/nicolargo/glances/blob/e907519c4a446da33b6968dba8f1c3b84a3379df/docker-files/ubuntu.Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/nicolargo/glances)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: binary: `pip:glances`

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Glances is one pip install into a venv under /app, with no extra services. Use the python sibling and read host metrics read-only, with state and cache in /tmp and /config.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [nicolargo/glances:ubuntu-4.3.0.8-full](https://hub.docker.com/r/nicolargo/glances)
- **copy-from arm64**: [nicolargo/glances:ubuntu-4.3.0.8-full](https://hub.docker.com/r/nicolargo/glances)

### Dependency containers

- **Dependency containers**: none
