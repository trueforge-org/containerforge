# fireflyiii

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: fireflyiii
- **Rows**: 1
- **Hard dependency containers**: yes (valkey)
- **Optional dependency containers**: yes (postgresql)
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/fireflyiii
- **Source repository**: https://github.com/firefly-iii/firefly-iii
- **Documentation**: https://docs.firefly-iii.org/
- **Website**: https://firefly-iii.org/

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/fireflyiii/core

## Base container

- **Foundation**: ubuntu (`ghcr.io/trueforge-org/ubuntu:26.4`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Laravel PHP app, with PHP provided by apt.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: fireflyiii
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/fireflyiii/core:version-6.2.21`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://dev.azure.com/Firefly-III/_git/MainImage?path=/Dockerfile&version=GBmain)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/firefly-iii/firefly-iii)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/firefly-iii/firefly-iii/releases/download/v6.2.21/FireflyIII-v6.2.21.tar.gz)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Laravel PHP app from a release zip, built on the serversideup php-fpm-nginx image. It runs several processes (nginx, php-fpm, scheduler) under s6, and needs an external postgres plus valkey. Rebuilding the php, nginx and cron stack on containerforge-ubuntu is substantial work.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [fireflyiii/core:version-6.2.21](https://hub.docker.com/r/fireflyiii/core)
- **copy-from arm64**: [fireflyiii/core:version-6.2.21](https://hub.docker.com/r/fireflyiii/core)

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

- **Dependency containers**: valkey ✅, postgresql ✅
