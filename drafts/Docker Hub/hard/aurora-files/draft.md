# aurora-files

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: aurora-files
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/aurora-files
- **Source repository**: https://github.com/afterlogic/aurora-files
- **Documentation**: https://afterlogic.com/docs
- **Website**: https://afterlogic.com/

## Potentially relevant resources

- **Source code repository**: https://github.com/afterlogic/docker-aurora-files
- **Container image**: https://hub.docker.com/r/afterlogic/docker-aurora-files

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: PHP app with nginx and php-fpm, with PHP provided by apt.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: nginx, php-fpm and PHP extensions (inferred)
- python/pip: none
- node/npm: none
- other: afterlogic vendor zip (not GitHub); composer (inferred)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 80/http (nginx web UI, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/aurora-files
- non-root: possible - chart sets runAsUser 0; nginx on port 80 needs root or a port change
- read-only-rootfs: possible - chart sets false; draft says the app writes into its own tree
- privileged: no - not set, common default false
- other-security: none
- extra-persistence: unknown - chart persistence is {}; app upload or data path not in values
- confidence: low

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: aurora-files
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/afterlogic/docker-aurora-files:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/afterlogic/docker-aurora-files/blob/master/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/afterlogic/aurora-files)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/afterlogic/aurora-files/releases)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: PHP 8.3 web app on alpine with nginx and php-fpm from apk, plus a vendor zip from afterlogic.org. Two services in one image need s6 or supervisor, and the app writes into its own tree, which needs rework for a read-only /app.

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
