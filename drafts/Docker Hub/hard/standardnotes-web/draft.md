# standardnotes-web

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: standardnotes-web
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/standardnotes-web
- **Source repository**: https://github.com/standardnotes/app
- **Documentation**: https://standardnotes.com/help
- **Website**: https://standardnotes.com/

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/standardnotes/web
- **Website**: https://standardnotes.org

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: standardnotes-web
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/standardnotes/web:stable`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/standardnotes/app/blob/main/packages/web/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/standardnotes/app)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Static JavaScript web client from the standardnotes/app monorepo, served by nginx:alpine. No public Dockerfile was found and the upstream repo could not be traced, so the bundle must be built from monorepo source with yarn before it can be served from the nginx sibling. Build effort is the main driver.

### amd64 / arm64

How we get the application for that architecture.

- `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.

- **amd64**: compile
- **arm64**: compile

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: no
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
