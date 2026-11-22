# xonotic

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: medium
- **Chart**: xonotic
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/xonotic
- **Source repository**: https://gitlab.com/xonotic/xonotic
- **Documentation**: https://gitlab.com/xonotic/xonotic/-/wikis/home
- **Website**: https://xonotic.org/

## Potentially relevant resources

- **Container image**: https://ghcr.io/ich777/xonotic
- **Website**: https://www.xonotic.org

## Base container

- **Primary**: ubuntu
- **Alternative**: none
- **Reason**: Native C dedicated server unpacked from the amd64 release.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: xonotic
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/ich777/xonotic:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/ich777/docker-xonotic-server/blob/master/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://gitlab.com/xonotic/xonotic)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://dl.xonotic.org/xonotic-0.8.6.zip)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Native C dedicated server plus data pack from the upstream release, which the image fetches at runtime on a debian base. No ContainerForge sibling exists. On ubuntu, unpack the amd64 release into /app, keep server config and maps in /config, and run one UDP process. Medium because arm64 needs a source compile.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.
- `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.

- **amd64**: yes
- **arm64**: compile

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [ghcr.io/ich777/xonotic:latest](https://ghcr.io/ich777/xonotic)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
