# mosdns

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: easy
- **Chart**: mosdns
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/mosdns
- **Source repository**: https://github.com/IrineSistiana/mosdns
- **Documentation**: https://irine-sistiana.gitbook.io/mosdns-wiki/
- **Documentation**: https://irine-sistiana.gitbook.io/mosdns-wiki

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: mosdns
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/601096721/mosdns:v5.3.4`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/Sagit-chu/mosdns-container/blob/HEAD/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/IrineSistiana/mosdns)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/IrineSistiana/mosdns/releases/download/v5.3.4/mosdns-linux-amd64.zip) · [arm64](https://github.com/IrineSistiana/mosdns/releases/download/v5.3.4/mosdns-linux-arm64.zip)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Go DNS forwarder. Upstream publishes prebuilt zips per arch, so the Dockerfile clone-and-compile is avoidable. Unzip the binary into /app on containerforge-ubuntu and run one process with its config in /config.

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
