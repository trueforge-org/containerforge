# twonky-server

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: twonky-server
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/twonky-server
- **Website**: https://www.twonky.com/download/

## Potentially relevant resources

- **Source code repository**: https://github.com/H2CK/twonkyserver
- **Container image**: https://hub.docker.com/r/dtjs48jkt/twonkyserver

## Base container

- **Foundation**: ubuntu (`ghcr.io/trueforge-org/ubuntu:26.4`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Closed-source x86-64 server binary installed on ubuntu.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: twonky-server
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/dtjs48jkt/twonkyserver:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/H2CK/twonkyserver/blob/a4d34f54e62617b359df5bf8dd745e4742d74c2e/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://www.twonky.com/download/)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](http://download.twonky.com/8.5.2/twonky-x86-64-glibc-2.22-8.5.2.zip)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Closed-source Twonky server, but the vendor zip (8.5.2, glibc x86-64) is publicly downloadable, so it is not very-hard. Runs as root in the upstream image and pulls a static ffmpeg. Package it on containerforge-ubuntu under /app with media and state in /config; x86-64 only as built upstream.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.
- `no`: neither works for that architecture, for example closed-source software where the vendor only ships an amd64 executable.
- A trailing `*` means the claim could not be confirmed against the upstream source, so it is a best judgement and should be rechecked before porting.

- **amd64**: yes*
- **arm64**: no*

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [dtjs48jkt/twonkyserver:latest](https://hub.docker.com/r/dtjs48jkt/twonkyserver)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
