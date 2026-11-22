# fastcom-mqtt

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: fastcom-mqtt
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/fastcom-mqtt
- **Source repository**: https://github.com/simonjenny/fastcom-mqtt

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/simonjenny/fastcom-mqtt

## Base container

- **Primary**: python-node
- **Alternative**: none
- **Reason**: Node app with a headless browser and MQTT clients from apt; python-node covers the Node runtime.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: fastcom-mqtt
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/simonjenny/fastcom-mqtt:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/simonjenny/fastcom-mqtt/blob/ce67907/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/simonjenny/fastcom-mqtt)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/simonjenny/fastcom-mqtt/releases)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Node 14 app with Chrome and mosquitto-clients installed from apt, and puppeteer and fast-cli from npm. Node 14 is EOL, so it should move to a supported node version. Chrome needs /tmp profiles and a non-root user.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [simonjenny/fastcom-mqtt:latest](https://hub.docker.com/r/simonjenny/fastcom-mqtt)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
