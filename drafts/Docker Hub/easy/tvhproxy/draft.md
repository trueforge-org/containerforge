# tvhproxy

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: easy
- **Chart**: tvhproxy
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/tvhproxy
- **Source repository**: https://github.com/jkaberg/tvhProxy

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/chvb/docker-tvhproxy

## Base container

- **Foundation**: ubuntu (`ghcr.io/trueforge-org/ubuntu:26.4`), which every ContainerForge runtime image is built on
- **Runtime image**: python
- **Reason**: Single Flask script installed with pip.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: tvhproxy
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/chvb/docker-tvhproxy:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/chvb/docker-tvhproxy/blob/c1ed49d8924d9f5a16d581a1684c33d747d2111e/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/jkaberg/tvhProxy)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/jkaberg/tvhProxy/archive/refs/heads/master.zip)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Single Python Flask script (tvhProxy.py) with a few pip packages on alpine 3.6, one process. Use the python sibling, pip install flask into /app and pin the script instead of the unpinned master download at build time.

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
