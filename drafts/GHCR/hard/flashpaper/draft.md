# flashpaper

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: hard
- **Chart**: flashpaper
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/flashpaper
- **Source repository**: https://github.com/AndrewPaglusch/FlashPaper

## Potentially relevant resources

- **Container image**: https://ghcr.io/andrewpaglusch/flashpaper
- **Source code repository**: https://github.com/andrewpaglusch/FlashPaper/pkgs/container/flashpaper

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Alternative runtime image**: [nginx](https://github.com/trueforge-org/containerforge/tree/main/apps/nginx) (`ghcr.io/trueforge-org/nginx`)
- **Reason**: PHP via apt on ubuntu per the PHP rule; nginx is the alternative web frontend.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: php-fpm, php-curl, curl, nginx (inferred)
- python/pip: none
- node/npm: none
- other: composer (inferred), FlashPaper v2.6.0 source

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 80/http (nginx and PHP-FPM web app, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/flashpaper
- non-root: no - chart forces runAsUser 0 and runAsGroup 0 (PHP and nginx)
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - not set, default false
- other-security: none in values
- extra-persistence: /var/www/html/data (type not set, likely pvc)
- confidence: medium

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: paste data is stored under /var/www/html/data, not /config, so the persistence path must be mounted explicitly or pastes are lost on rebuild (inferred).
- caveat: the chart pins the rolling master tag of a third-party image, so the app version can change without warning.
- caveat: nginx and PHP-FPM run together under a supervisor, so the container needs a process manager and the upstream project is small (inferred).

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: flashpaper
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/andrewpaglusch/flashpaper:master`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/AndrewPaglusch/FlashPaper/blob/7c986b3f712563c085762eba68cf29f744acc7ea/docker/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/AndrewPaglusch/FlashPaper)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/AndrewPaglusch/FlashPaper/releases/tag/v2.6.0)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: PHP-FPM app served through nginx, with curl added to php:8.5-fpm-alpine upstream. PHP is not a ContainerForge base, and nginx plus php-fpm are two processes that need a supervisor. Making it rootless and read-only needs real rework.

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
