# deepstack

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: deepstack
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/deepstack
- **Source repository**: https://github.com/johnolafenwa/DeepStack
- **Documentation**: https://docs.deepstack.cc
- **Website**: https://deepstack.cc

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/deepquestai/deepstack
- **Website**: https://www.deepstack.cc

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: deepstack
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/deepquestai/deepstack:cpu-2022.01.1`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/johnolafenwa/DeepStack/blob/73b6f7ab0f9a8acc8f7a49c6f13594fe470de042/Dockerfile.cpu)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/johnolafenwa/DeepStack)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: DeepStack CPU server: a Go server plus a Python AI model stack built on a deepstack-base image with a legacy 2022 toolchain. Large ML stack with several processes and a GPU variant, so rebuilding and running it rootless is a big job.

### amd64 / arm64

How we get the application for that architecture.

- `no`: neither works for that architecture, for example closed-source software where the vendor only ships an amd64 executable.
- A trailing `*` means the claim could not be confirmed against the upstream source, so it is a best judgement and should be rechecked before porting.

- **amd64**: no*
- **arm64**: no*

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

A path in backticks is where the binary sits inside the image.

- **copy-from amd64**: [deepquestai/deepstack:cpu-2022.01.1](https://hub.docker.com/r/deepquestai/deepstack) (`/app/server and python env, path unverified`)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
