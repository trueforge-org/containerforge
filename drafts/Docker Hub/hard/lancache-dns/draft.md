# lancache-dns

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: lancache-dns
- **Rows**: 1
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **Source repository**: https://github.com/lancachenet/lancache-dns

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: lancache-dns
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/lancachenet/lancache-dns:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/lancachenet/lancache-dns/blob/6b4b60e/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/lancachenet/lancache-dns)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: binary: `apt:bind9`

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: bind9 from apt plus a Go dnstool helper and cache-domains git-cloned at build time on lancachenet/ubuntu. It must listen on port 53, which needs root or a capability unless remapped, and runs several processes, so it needs rework for rootless and read-only root.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [lancachenet/lancache-dns:latest](https://hub.docker.com/r/lancachenet/lancache-dns)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
