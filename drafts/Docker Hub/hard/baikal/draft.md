# baikal

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: baikal
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/baikal
- **Source repository**: https://github.com/sabre-io/Baikal
- **Documentation**: https://sabre.io/baikal/
- **Website**: https://sabre.io/baikal/

## Potentially relevant resources

- **Source code repository**: https://github.com/ckulka/baikal-docker
- **Container image**: https://hub.docker.com/r/ckulka/baikal

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: PHP CalDAV server served by nginx with php-fpm, with PHP provided by apt.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: nginx, php-fpm and PHP extensions such as sqlite3, xml, mbstring, curl (inferred)
- python/pip: none
- node/npm: none
- other: none (release zip 0.13.0 is pure PHP)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 80/http (CalDAV/CardDAV web, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/baikal
- non-root: possible - chart sets runAsUser 0; nginx on port 80 needs root or a port change, and php-fpm needs rework
- read-only-rootfs: possible - chart sets false; draft says read-only config handling needs rework
- privileged: no - not set, common default false
- other-security: none
- extra-persistence: /var/www/baikal/config (pvc, chart mount; draft uses /config); /var/www/baikal/Specific (pvc)
- confidence: medium

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: baikal
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/ckulka/baikal:0.10.1-nginx`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/ckulka/baikal-docker/blob/06c53989a648198501cce322bd200221a5e1e136/nginx.dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/sabre-io/Baikal)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/sabre-io/Baikal/releases/download/0.13.0/baikal-0.13.0.zip)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: PHP CalDAV/CardDAV server (Baikal) served by nginx with php-fpm, so nginx and php-fpm must run together in one container. Needs rootless rework for both processes and read-only config handling; the release zip itself is pure PHP.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ckulka/baikal:0.10.1-nginx](https://hub.docker.com/r/ckulka/baikal)
- **copy-from arm64**: [ckulka/baikal:0.10.1-nginx](https://hub.docker.com/r/ckulka/baikal)

### Dependency containers

- **Dependency containers**: none
