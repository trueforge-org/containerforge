# multus-cni

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: hard
- **Chart**: multus-cni
- **Rows**: 1
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **Source repository**: https://github.com/k8snetworkplumbingwg/multus-cni

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: multus-cni
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/k8snetworkplumbingwg/multus-cni:v4.3.2-thick`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/k8snetworkplumbingwg/multus-cni/blob/v4.3.2/images/Dockerfile.thick)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/k8snetworkplumbingwg/multus-cni)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/k8snetworkplumbingwg/multus-cni/releases/download/v4.3.2/multus-cni_4.3.2_linux_amd64.tar.gz) · [arm64](https://github.com/k8snetworkplumbingwg/multus-cni/releases/download/v4.3.2/multus-cni_4.3.2_linux_arm64.tar.gz)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Thick CNI plugin daemon in Go that needs host networking, root and hostPath mounts such as /opt/cni/bin; the image only copies binaries. It can be shipped on containerforge-ubuntu from the release tarball, but it cannot run rootless and needs host paths, so hard.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/k8snetworkplumbingwg/multus-cni:v4.3.2-thick](https://ghcr.io/k8snetworkplumbingwg/multus-cni)
- **copy-from arm64**: [ghcr.io/k8snetworkplumbingwg/multus-cni:v4.3.2-thick](https://ghcr.io/k8snetworkplumbingwg/multus-cni)

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, CNPG PostgreSQL, sidecars).

❌ means it is missing too.

- **Dependency containers**: crane (craneImage) ❌, cni (talosCniImage) ❌
