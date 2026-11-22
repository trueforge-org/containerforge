# octoprint

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: octoprint
- **Rows**: 1
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **Source repository**: https://github.com/OctoPrint/OctoPrint

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: octoprint
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/octoprint/octoprint:1.11.8`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/OctoPrint/octoprint-docker/blob/32fdd6eae2a9a2c1f97f26cf4c7d3802cb0559db/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/OctoPrint/OctoPrint)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: binary: `pip:OctoPrint`

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: OctoPrint is pure Python installed by pip on the python sibling, so the runtime is easy. The hard part is serial and USB printer access, which needs device mounts and dialout group access, so it is a hardware-bound image that is not fully rootless.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [octoprint/octoprint:1.11.8](https://hub.docker.com/r/octoprint/octoprint)
- **copy-from arm64**: [octoprint/octoprint:1.11.8](https://hub.docker.com/r/octoprint/octoprint)

### Dependency containers

- **Dependency containers**: none
