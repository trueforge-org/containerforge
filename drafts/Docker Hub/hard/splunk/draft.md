# splunk

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: splunk
- **Rows**: 1
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: splunk
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/splunk/splunk:10.6.2`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/splunk/docker-splunk/blob/a2c049c/splunk/common-files/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://www.splunk.com/en_us/download/splunk-enterprise.html)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://download.splunk.com/products/splunk/releases/10.6.2.5/linux/splunk-10.6.2.5-b07ce3b48d58-linux-amd64.tgz)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Splunk Enterprise is a large root-era stack with many internal services and an ansible-based setup. The tarball is downloaded from a URL with sha512 checks and unpacked into the image. Rootless read-only operation needs major rework.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.
- `no`: neither works for that architecture, for example closed-source software where the vendor only ships an amd64 executable.

- **amd64**: yes
- **arm64**: no

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [splunk/splunk:10.6.2](https://hub.docker.com/r/splunk/splunk)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
