# xteve

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: hard
- **Chart**: xteve
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/xteve
- **Source repository**: https://github.com/xteve-project/xTeVe

## Potentially relevant resources

- **Container image**: https://ghcr.io/k8s-at-home/xteve
- **Source code repository**: https://github.com/k8s-at-home/container-images

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: xteve
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/k8s-at-home/xteve:v2.2.0.200`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

`-` means no public Dockerfile could be found.

- **Dockerfile**: -

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/xteve-project/xTeVe)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/xteve-project/xTeVe-Downloads/raw/master/xteve_linux_amd64.zip) · [arm64](https://github.com/xteve-project/xTeVe-Downloads/raw/master/xteve_linux_arm64.zip)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: xTeVe is a Go IPTV proxy with prebuilt linux amd64 and arm64 zips, but no public Dockerfile exists for this k8s-at-home image and the project is archived. It would be unzipped into /app with config moved to /config and state to /tmp.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/k8s-at-home/xteve:v2.2.0.200](https://ghcr.io/k8s-at-home/xteve)
- **copy-from arm64**: [ghcr.io/k8s-at-home/xteve:v2.2.0.200](https://ghcr.io/k8s-at-home/xteve)

### Dependency containers

- **Dependency containers**: none
