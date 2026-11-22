# trango

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: trango
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/trango
- **Source repository**: https://github.com/trango-io/trango-self-hosted

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/tak786/trango-self-hosted
- **Website**: https://trango.io

## Base container

- **Foundation**: ubuntu (`ghcr.io/trueforge-org/ubuntu:26.4`), which every ContainerForge runtime image is built on
- **Runtime image**: python-node
- **Alternative runtime image**: ubuntu
- **Reason**: Node and Python runtimes cover most of the stack, with a C++ server that would need ubuntu as the alternative.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: trango
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/tak786/trango-self-hosted:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/trango-io/trango-self-hosted/blob/master/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/trango-io/trango-self-hosted)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Node/Python/C++ stack (nginx, flask, boost-built discovery server, nodejs 12) built from the public trango-io/trango-self-hosted repo on ubuntu 18.04. Several services in one image would need reworking for rootless and a read-only rootfs on containerforge-ubuntu, with no sibling covering it.

### amd64 / arm64

How we get the application for that architecture.

- `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.

- **amd64**: compile
- **arm64**: compile

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [tak786/trango-self-hosted:latest](https://hub.docker.com/r/tak786/trango-self-hosted)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
