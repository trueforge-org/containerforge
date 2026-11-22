# shapeshifter-obfuscator

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: shapeshifter-obfuscator
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/shapeshifter-obfuscator
- **Source repository**: https://github.com/OperatorFoundation/shapeshifter-dispatcher

## Potentially relevant resources

- **Source code repository**: https://github.com/juchong/shapeshifter-docker
- **Container image**: https://hub.docker.com/r/juchong/shapeshifter-docker

## Base container

- **Foundation**: ubuntu (`ghcr.io/trueforge-org/ubuntu:26.4`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Go binary compiled from source on ubuntu.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: shapeshifter-obfuscator
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/juchong/shapeshifter-docker:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/juchong/shapeshifter-docker/blob/d2857ae/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/OperatorFoundation/shapeshifter-dispatcher)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Go binary built from OperatorFoundation/shapeshifter-dispatcher, git-cloned without a pinned ref on alpine using go build and go install. We would compile it in a Go stage on containerforge-ubuntu after pinning a tag. The source is small, but upstream publishes no release assets.

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
