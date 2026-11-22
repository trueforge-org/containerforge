# pocketmine-mp

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: medium
- **Chart**: pocketmine-mp
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/pocketmine-mp
- **Source repository**: https://github.com/pmmp/PocketMine-MP
- **Documentation**: https://doc.pmmp.io/en/rtfd/installation.html
- **Website**: https://pmmp.io

## Potentially relevant resources

- **Container image**: https://ghcr.io/pmmp/pocketmine-mp

## Base container

- **Foundation**: ubuntu (`ghcr.io/trueforge-org/ubuntu:26.4`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Runs a PHP phar on a PHP binary, and PHP is not a base; use PHP from apt.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: pocketmine-mp
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/pmmp/pocketmine-mp:5.44.3`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/pmmp/PocketMine-MP/blob/5.44.3/docker/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/pmmp/PocketMine-MP)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/pmmp/PocketMine-MP/releases/download/5.44.3/PocketMine-MP.phar)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Release PocketMine-MP.phar plus pmmp PHP 8.4 binary tarball for amd64; arm64 must compile pmmp PHP with the php-build-scripts. PHP is not a ContainerForge runtime. Single rootless process, data and plugins under /config.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.
- `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.

- **amd64**: yes
- **arm64**: compile

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [ghcr.io/pmmp/pocketmine-mp:5.44.3](https://ghcr.io/pmmp/pocketmine-mp)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
