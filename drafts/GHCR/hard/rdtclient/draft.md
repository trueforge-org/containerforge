# rdtclient

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: hard
- **Chart**: rdtclient
- **Rows**: 1
- **Hard dependency containers**: no
- **Soft dependency containers**: yes (aria2 (aria2Image))
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **Source repository**: https://github.com/rogerfar/rdt-client

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: rdtclient
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/rogerfar/rdtclient:2.0.143`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/rogerfar/rdt-client/blob/a669bd3/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/rogerfar/rdt-client)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/rogerfar/rdt-client/releases/download/v2.0.143/RealDebridClient.zip)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: RDT Client is a .NET server with a node-built web client; the release ships RealDebridClient.zip, but ContainerForge has no .NET runtime base, so the runtime must be added. The chart also pairs it with an aria2 sidecar (reuse aria2) and the upstream linuxserver s6 base needs rework for rootless read-only use.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.
- A trailing `*` means the claim could not be confirmed against the upstream source, so it is a best judgement and should be rechecked before porting.

- **amd64**: yes*
- **arm64**: yes*

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: no
- **copy-from arm64**: no

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, CNPG PostgreSQL, sidecars).

❌ means it is missing too.

- **Dependency containers**: aria2-pro (aria2Image) ❌
