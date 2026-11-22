# wizarr

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: medium
- **Chart**: wizarr
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/wizarr
- **Source repository**: https://github.com/Wizarrrr/wizarr
- **Documentation**: https://docs.wizarr.dev/

## Potentially relevant resources

- **Container image**: https://ghcr.io/wizarrrr/wizarr

## Base container

- **Primary**: python
- **Alternative**: none
- **Reason**: Flask app managed with uv on the python base.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: wizarr
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/wizarrrr/wizarr:v2026.10.1`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/Wizarrrr/wizarr/blob/936143363897efd3ca68568fdf6fdd9a0d63f559/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/Wizarrrr/wizarr)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/Wizarrrr/wizarr/archive/refs/tags/v2026.10.1.tar.gz)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Python Flask app managed with uv, plus npm-built static assets, so it fits the python and node stacks ContainerForge already has. Install the venv into /app at build time, keep the sqlite database under /config, and keep uv caches in /tmp.

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
