# anonaddy

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: anonaddy
- **Rows**: 1
- **Hard dependency containers**: yes (mariadb)
- **Optional dependency containers**: yes (valkey)
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/anonaddy
- **Source repository**: https://github.com/anonaddy/anonaddy
- **Documentation**: https://addy.io/help/
- **Website**: https://addy.io/

## Potentially relevant resources

- **Source code repository**: https://github.com/anonaddy/docker
- **Container image**: https://hub.docker.com/r/anonaddy/anonaddy

## Base container

- **Foundation**: ubuntu (`ghcr.io/trueforge-org/ubuntu:26.4`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: PHP app needing php-fpm and mail services, with PHP provided by apt.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: anonaddy
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/anonaddy/anonaddy:1.7.4`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/anonaddy/docker/blob/e3f8bd3d009bab256dba3033f8c5f100198439e6/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/anonaddy/anonaddy)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/anonaddy/anonaddy/releases/tag/v1.7.4)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Laravel email alias service that needs postfix, dovecot, php-fpm and a web server, all in one crazymax s6 image. That is several services plus mail ports and writable paths, so it is real rework. mariadb and valkey siblings cover the database and cache.

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

- **Dependency containers**: mariadb ✅, valkey ✅
