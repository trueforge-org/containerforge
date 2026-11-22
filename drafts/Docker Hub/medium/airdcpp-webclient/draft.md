# airdcpp-webclient

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: airdcpp-webclient
- **Rows**: 1
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: airdcpp-webclient
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/gangefors/airdcpp-webclient:2.14.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/gangefors/docker-airdcpp-webclient/blob/master/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/airdcpp-web/airdcpp-webclient)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://web-builds.airdcpp.net/stable/airdcpp_latest_master_64-bit_portable.tar.gz)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: airdcpp C++ daemon plus web UI on containerforge-ubuntu with Node for extensions; amd64 unpacks the vendor portable tarball into /app, arm64 needs a CMake build (Boost and other dev packages) because no arm64 tarball exists. Config dir must move to /config.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.
- `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.

- **amd64**: yes
- **arm64**: compile

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [gangefors/airdcpp-webclient:2.14.0](https://hub.docker.com/r/gangefors/airdcpp-webclient)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
