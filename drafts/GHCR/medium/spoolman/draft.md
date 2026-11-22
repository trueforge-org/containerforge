# spoolman

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: medium
- **Chart**: spoolman
- **Rows**: 1
- **Hard dependency containers**: yes (postgresql (CNPG))
- **Soft dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **Source repository**: https://github.com/Donkie/Spoolman
- **Documentation**: https://donkie.github.io/Spoolman/

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: spoolman
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/donkie/spoolman:0.27.1`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/Donkie/Spoolman/blob/ff8efd517b76a4b2783f29c89e9b9fbcd8cd167b/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/Donkie/Spoolman)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/Donkie/Spoolman/releases/download/v0.27.1/spoolman.zip)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Python 3.14 app installed by pip (uv venv) into /app; reuse the python ContainerForge sibling and keep SQLite data under /config, or use external Postgres via cnpg. Mostly pure-Python dependencies, one process, and the upstream root entrypoint needs a small path change for non-root use.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/donkie/spoolman:0.27.1](https://ghcr.io/donkie/spoolman)
- **copy-from arm64**: [ghcr.io/donkie/spoolman:0.27.1](https://ghcr.io/donkie/spoolman)

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, CNPG PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

- **Dependency containers**: postgresql (CNPG) ✅
