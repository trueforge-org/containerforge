# portainer

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: portainer
- **Rows**: 1
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **Source repository**: https://github.com/portainer/portainer
- **Documentation**: https://docs.portainer.io/
- **Website**: https://www.portainer.io/

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: portainer
- **Role**: sidecar (beImage)

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/portainer/portainer-ee:3.1.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

`-` means no public Dockerfile could be found.

- **Dockerfile**: -

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/portainer/portainer)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Closed-source Portainer Business Edition; no public Dockerfile. Binary and UI could be extracted from the official image but redistribution is licence-restricted, and it needs the Docker socket and /data. A CE sibling is the practical alternative.

### amd64 / arm64

How we get the application for that architecture.

- `no`: neither works for that architecture, for example closed-source software where the vendor only ships an amd64 executable.

- **amd64**: no
- **arm64**: no

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

A path in backticks is where the binary sits inside the image.

- **copy-from amd64**: [portainer/portainer-ee:latest](https://hub.docker.com/r/portainer/portainer-ee) (`/portainer and /public`)
- **copy-from arm64**: [portainer/portainer-ee:latest](https://hub.docker.com/r/portainer/portainer-ee) (`/portainer and /public`)

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, CNPG PostgreSQL, sidecars).

- **Dependency containers**: -
