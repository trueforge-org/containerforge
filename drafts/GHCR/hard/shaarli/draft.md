# shaarli

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: hard
- **Chart**: shaarli
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/shaarli
- **Source repository**: https://github.com/shaarli/Shaarli
- **Documentation**: https://shaarli.readthedocs.io/

## Potentially relevant resources

- **Container image**: https://ghcr.io/shaarli/shaarli

## Base container

- **Primary**: ubuntu
- **Alternative**: nginx
- **Reason**: PHP app, so PHP via apt on ubuntu with nginx as the web server.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: shaarli
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/shaarli/shaarli:v0.16.10`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/shaarli/Shaarli/blob/v0.16.10/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/shaarli/Shaarli)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/shaarli/Shaarli/releases/download/v0.16.10/shaarli-v0.16.10-full.zip)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Shaarli is a PHP app built with composer and a node asset stage, and upstream runs it under s6 with a web server and PHP-FPM. PHP is not a ContainerForge runtime, and the multi-process layout needs rework for a read-only rootfs with data in /config. Source is interpreted, so no compile is needed.

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
