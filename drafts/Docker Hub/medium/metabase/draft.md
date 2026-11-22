# metabase

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: metabase
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: yes (postgresql)
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/metabase
- **Source repository**: https://github.com/metabase/metabase
- **Documentation**: https://www.metabase.com/docs/latest/
- **Website**: https://www.metabase.com

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/metabase/metabase

## Base container

- **Primary**: java25
- **Alternative**: none
- **Reason**: The input names Java 25 and the java25 sibling for a jar.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: metabase
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/metabase/metabase:v0.65.6`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/metabase/metabase/blob/v0.65.6/bin/docker/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/metabase/metabase)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://downloads.metabase.com/v0.65.6/metabase.jar)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Java 25 runtime needed, which the java25 sibling already provides. Copy the upstream metabase.jar uberjar into /app and run it as apps with the database in PostgreSQL Postgres and state in /config. Jar is pure JVM, so no compile step.

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

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

- **Dependency containers**: postgresql ✅
