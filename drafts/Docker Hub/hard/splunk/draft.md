# splunk

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: splunk
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/splunk
- **Website**: https://www.splunk.com/en_us/download/splunk-enterprise.html
- **Documentation**: https://docs.splunk.com/Documentation/Splunk
- **Documentation**: https://help.splunk.com/en

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/splunk/splunk
- **Website**: https://splunk.github.io/docker-splunk

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Guess: a large vendor stack with bundled runtimes and no runtime named, so ubuntu is the default.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: ansible (inferred)
- node/npm: none
- other: Splunk Enterprise amd64 tgz from download.splunk.com

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8000/http (web UI), 8089/https (management API), 9997/tcp (forwarder receiving)

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
