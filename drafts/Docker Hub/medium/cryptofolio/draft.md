# cryptofolio

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: cryptofolio
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/cryptofolio
- **Source repository**: https://github.com/Xtrendence/cryptofolio

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/xtrendence/cryptofolio

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Alternative runtime image**: [nginx](https://github.com/trueforge-org/containerforge/tree/main/apps/nginx) (`ghcr.io/trueforge-org/nginx`)
- **Reason**: PHP web app with PHP from apt on ubuntu, served by a web server.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: cryptofolio
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/xtrendence/cryptofolio:V.2.2.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/Xtrendence/cryptofolio/blob/51f7263e77cad118bd8f2244d0ded81e5d647261/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/Xtrendence/cryptofolio)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/Xtrendence/Cryptofolio/releases/download/V.2.2/API-And-Website.zip)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: PHP web app copied into php:7.4-apache, and PHP 7.4 is EOL. ContainerForge has no PHP sibling, so PHP runtime comes from apt on containerforge-ubuntu and the app is served with nginx or apache. Interpreted PHP needs no compile.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [xtrendence/cryptofolio:V.2.2.0](https://hub.docker.com/r/xtrendence/cryptofolio)
- **copy-from arm64**: [xtrendence/cryptofolio:V.2.2.0](https://hub.docker.com/r/xtrendence/cryptofolio)

### Dependency containers

- **Dependency containers**: none
