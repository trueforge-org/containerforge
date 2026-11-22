# rss-to-telegram

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: rss-to-telegram
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/rss-to-telegram
- **Source repository**: https://github.com/BoKKeR/RSS-to-Telegram-Bot

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/bokker/rss.to.telegram

## Base container

- **Primary**: python-node
- **Alternative**: none
- **Reason**: Node.js bot built with npm, so python-node provides node.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: rss-to-telegram
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/bokker/rss.to.telegram:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/BoKKeR/RSS-to-Telegram-Bot/blob/3675d2e9c4d9731cec685a8417f7b724e2921e9a/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/BoKKeR/RSS-to-Telegram-Bot)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/BoKKeR/RSS-to-Telegram-Bot/releases/tag/2.0.9)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Node.js bot built with npm ci and npm run build in a builder stage, then copied onto a Node runtime; the old Node 16 base should move to the ContainerForge node sibling. Pure JavaScript, one process, state written to /config.

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
