# clusterissuer

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: easy
- **Chart**: clusterissuer
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/clusterissuer
- **Source repository**: https://github.com/docker-library/hello-world

## Potentially relevant resources

- **Website**: https://cert-manager.io
- **Container image**: https://hub.docker.com/_/hello-world

## Base container

- **Foundation**: ubuntu (`ghcr.io/trueforge-org/ubuntu:26.4`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Placeholder static binary that needs no runtime, so the ubuntu base is enough.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: clusterissuer
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `hello-world:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/docker-library/hello-world/blob/522bcd2faf422c60b9d20e64d7cd6d56600aec97/amd64/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/docker-library/hello-world)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/docker-library/hello-world/raw/522bcd2faf422c60b9d20e64d7cd6d56600aec97/amd64/hello) · [arm64](https://github.com/docker-library/hello-world/raw/522bcd2faf422c60b9d20e64d7cd6d56600aec97/arm64v8/hello)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Placeholder hello-world image built FROM scratch with a prebuilt static binary, so it needs no runtime or build work. Port by copying the same static binary into the ContainerForge base or using the same scratch image pattern.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.
- A trailing `*` means the claim could not be confirmed against the upstream source, so it is a best judgement and should be rechecked before porting.

- **amd64**: yes*
- **arm64**: yes*

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [hello-world:latest](https://hub.docker.com/_/hello-world)
- **copy-from arm64**: [hello-world:latest](https://hub.docker.com/_/hello-world)

### Dependency containers

- **Dependency containers**: none
