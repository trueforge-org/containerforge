# ispy-agent-dvr

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: ispy-agent-dvr
- **Rows**: 1
- **Hard dependency containers**: no
- **Soft dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **Website**: https://www.ispyconnect.com/
- **Documentation**: https://www.ispyconnect.com/docs/agent/

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: ispy-agent-dvr
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/doitandbedone/ispyagentdvr:7.1.8.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/doitandbedone/ispyagentdvr-docker/blob/7.1.8.0/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://www.ispyconnect.com/)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://files.ispyconnect.com/downloads/Agent_Linux64_8_2_9_0.zip) · [arm64](https://files.ispyconnect.com/downloads/Agent_LinuxARM64_8_2_9_0.zip)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Closed-source Agent DVR (.NET) distributed as a vendor zip per arch, unzipped onto containerforge-ubuntu with libgdiplus, ffmpeg and tzdata. Needs camera/hardware-acceleration device access, a TURN server port range and writable state in /config, so rootless/read-only rework is real work.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [doitandbedone/ispyagentdvr:7.1.8.0](https://hub.docker.com/r/doitandbedone/ispyagentdvr)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
