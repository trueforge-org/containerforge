# humhub

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: medium
- **Chart**: humhub
- **Rows**: 1
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: humhub
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/mriedmann/humhub-phponly:1.17.2`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/mriedmann/humhub-docker/blob/6bb3dc908c7af3a930d500397d9394280cd55753/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/humhub/humhub)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/humhub/humhub/releases/tag/v1.17.2)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: PHP HumHub application from the humhub/humhub release tarball, served by php-fpm with nginx as a second image. Needs a PHP runtime that is not in the ContainerForge base list, plus an external MariaDB. Two images and the PHP stack add moderate effort.

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

Other containers the chart needs (Chart.yaml dependencies, CNPG PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

❌ means it is missing too.

- **Dependency containers**: mariadb ✅, valkey ✅, humhub-nginx (nginxImage) ❌
