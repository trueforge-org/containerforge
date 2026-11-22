# pingvin-share

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: medium
- **Chart**: pingvin-share
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/pingvin-share
- **Source repository**: https://github.com/stonith404/pingvin-share
- **Documentation**: https://stonith404.github.io/pingvin-share/

## Potentially relevant resources

- **Container image**: https://ghcr.io/stonith404/pingvin-share

## Base container

- **Primary**: python-node
- **Alternative**: none
- **Reason**: Next.js frontend and NestJS backend, both Node.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: pingvin-share
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/stonith404/pingvin-share:v1.13.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/stonith404/pingvin-share/blob/dd546b4f17a516ef696ea35b96bbac8ff5521e2a/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/stonith404/pingvin-share)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/stonith404/pingvin-share/releases/tag/v1.13.0)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Pingvin Share has a Next.js frontend and a NestJS backend, both built from source with npm and copied into a node runner on the node sibling. It is a single Node stack with Prisma and upload storage that must move to /config. The build steps are the main work.

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
