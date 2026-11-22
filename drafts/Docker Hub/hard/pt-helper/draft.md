# pt-helper

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: pt-helper
- **Rows**: 1
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: pt-helper
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/crazyq/pt_helper:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

`-` means no public Dockerfile could be found.

- **Dockerfile**: -

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://hub.docker.com/r/crazyq/pt_helper)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Closed-source image with no source or Dockerfile; app files would be copied from the vendor image, so runtime, glibc compatibility and layout are unverified. Redistribution terms are unknown and the image presumably needs writable data under /config.

### amd64 / arm64

How we get the application for that architecture.

- `no`: neither works for that architecture, for example closed-source software where the vendor only ships an amd64 executable.
- A trailing `*` means the claim could not be confirmed against the upstream source, so it is a best judgement and should be rechecked before porting.

- **amd64**: no*
- **arm64**: no*

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

A path in backticks is where the binary sits inside the image.

- **copy-from amd64**: [crazyq/pt_helper:latest](https://hub.docker.com/r/crazyq/pt_helper) (`app files, path not verified`)
- **copy-from arm64**: [crazyq/pt_helper:latest](https://hub.docker.com/r/crazyq/pt_helper) (`app files, path not verified`)

### Dependency containers

- **Dependency containers**: none
