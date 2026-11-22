# xen-orchestra

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: xen-orchestra
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/xen-orchestra
- **Source repository**: https://github.com/vatesfr/xen-orchestra
- **Documentation**: https://docs.xen-orchestra.com/
- **Website**: https://xen-orchestra.com/

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: xen-orchestra
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/ronivay/xen-orchestra:5.213.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/ronivay/xen-orchestra-docker/blob/0be1b1f87e7895d3cc0091c4088fbfc97317687e/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/vatesfr/xen-orchestra)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/vatesfr/xen-orchestra/releases)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Node monorepo cloned from master and built with yarn into a large dist, so the build is heavy and not pinned. It needs redis and a separate xo-server runtime with several internal services. Repackaging and pinning the build is the main effort.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [ronivay/xen-orchestra:5.213.0](https://hub.docker.com/r/ronivay/xen-orchestra)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
