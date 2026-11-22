# invidious

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Quay
- **Difficulty**: hard
- **Chart**: invidious
- **Rows**: 1
- **Hard dependency containers**: yes (postgresql)
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/invidious
- **Source repository**: https://github.com/iv-org/invidious

## Potentially relevant resources

- **Website**: https://docs.invidious.io/installation/#docker
- **Container image**: https://quay.io/invidious/invidious

## Base container

- **Primary**: ubuntu
- **Alternative**: none
- **Reason**: Crystal app compiled to a glibc binary on the ubuntu base.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: invidious
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `quay.io/invidious/invidious:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/iv-org/invidious/blob/4e9d20ddae3c23e4764df056d2e820aee04feef7/docker/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/iv-org/invidious)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Crystal app built with shards on containerforge-ubuntu using the upstream crystal linux-x86_64 or linux-aarch64 toolchain tarball (not apt on arm64), producing a glibc binary. Needs PostgreSQL as a separate service and static assets under /app; writes only to /tmp.

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

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

- **Dependency containers**: postgresql ✅
