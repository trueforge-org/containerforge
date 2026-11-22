# yourls

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: yourls
- **Rows**: 1
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: yourls
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `yourls:1.10.6`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/YOURLS/containers/blob/ab773d7d9e7408f66b532736ceea60324b9f3e3f/images/yourls/Dockerfile.template)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/YOURLS/YOURLS)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/YOURLS/YOURLS/archive/refs/tags/1.10.6.zip)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: PHP URL shortener from a release zip, using PHP with MySQL or MariaDB via the mariadb sibling. Port by installing PHP from apt and copying the release into /app, with config under /config and the sqlite or mysql connection set by env.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [yourls:1.10.6](https://hub.docker.com/_/yourls)
- **copy-from arm64**: [yourls:1.10.6](https://hub.docker.com/_/yourls)

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, CNPG PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

- **Dependency containers**: mariadb ✅
