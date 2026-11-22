# photo-stream

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: photo-stream
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/photo-stream
- **Source repository**: https://github.com/waschinski/photo-stream

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/waschinski/photo-stream

## Base container

- **Foundation**: ubuntu (`ghcr.io/trueforge-org/ubuntu:26.4`), which every ContainerForge runtime image is built on
- **Runtime image**: nginx
- **Alternative runtime image**: ubuntu
- **Reason**: Jekyll site built once and served as static files, so nginx serves it; ubuntu is the alternative if the build runs there.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: photo-stream
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/waschinski/photo-stream:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/waschinski/photo-stream/blob/4f4e0dd71bea2a1db063f03f6ba76ca1ffe02d29/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/waschinski/photo-stream)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/waschinski/photo-stream/releases/tag/1.5.0)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Jekyll static site that the image runs with jekyll serve, needing Ruby gems and a writable _site. ContainerForge can build the site once with Ruby in a build stage and serve it from the nginx sibling. Ruby gems ship prebuilt platform variants.

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
