# blocky

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: easy
- **Chart**: blocky
- **Rows**: 2
- **Hard dependency containers**: no
- **Soft dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **Source repository**: https://github.com/0xERR0R/blocky
- **Source repository**: https://github.com/k8s-gateway/k8s_gateway
- **Documentation**: https://0xerr0r.github.io/blocky/latest/

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- Row 1: **Chart**: blocky
- Row 1: **Role**: main
- Row 2: **Chart**: blocky
- Row 2: **Role**: sidecar (k8sgatewayImage)

### Container

The image and tag the chart uses today.

- Row 1: **Container**: `ghcr.io/0xerr0r/blocky:v0.36.0`
- Row 2: **Container**: `ghcr.io/k8s-gateway/k8s_gateway:1.8.2`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- Row 1: **Dockerfile**: [Dockerfile](https://github.com/0xERR0R/blocky/blob/2d6f7d4be5e39717c9ebb66c365d7ab2ae620edd/Dockerfile)
- Row 2: **Dockerfile**: [Dockerfile](https://github.com/k8s-gateway/k8s_gateway/blob/fc34def22c7802832aa10870b1fa8bbe310fe541/Dockerfile)

### Application source

The application's own source repository or project page.

- Row 1: **Application source**: [source](https://github.com/0xERR0R/blocky)
- Row 2: **Application source**: [source](https://github.com/k8s-gateway/k8s_gateway)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- Row 1: **Application binary**: [amd64](https://github.com/0xERR0R/blocky/releases/download/v0.36.0/blocky_v0.36.0_Linux_x86_64.tar.gz) · [arm64](https://github.com/0xERR0R/blocky/releases/download/v0.36.0/blocky_v0.36.0_Linux_arm64.tar.gz)
- Row 2: **Application binary**: [amd64](https://github.com/k8s-gateway/k8s_gateway/releases/download/v1.8.2/k8s_gateway_1.8.2_linux_amd64.tar.gz) · [arm64](https://github.com/k8s-gateway/k8s_gateway/releases/download/v1.8.2/k8s_gateway_1.8.2_linux_arm64.tar.gz)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- Row 1: **Difficulty**: easy
- Row 2: **Difficulty**: easy

### Reason

- Row 1: **Reason**: Single Go binary, and upstream publishes a per-arch Linux tarball, so ubuntu can install the release binary with no compile. Blocky serves DNS on port 53, so set a high port or allow a bind capability. The k8s_gateway sidecar is a CoreDNS Go build that would need compiling for both arches.
- Row 2: **Reason**: CoreDNS with the k8s_gateway plugin compiled in: a static Go binary available as a release tarball per arch. Place it in /app on containerforge-ubuntu; binding port 53 needs a high port or CAP_NET_BIND_SERVICE, otherwise rootless.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- Row 1: **amd64**: yes
- Row 1: **arm64**: yes
- Row 2: **amd64**: yes
- Row 2: **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- Row 1: **copy-from amd64**: [ghcr.io/0xerr0r/blocky:v0.36.0](https://ghcr.io/0xerr0r/blocky)
- Row 1: **copy-from arm64**: [ghcr.io/0xerr0r/blocky:v0.36.0](https://ghcr.io/0xerr0r/blocky)
- Row 2: **copy-from amd64**: [ghcr.io/k8s-gateway/k8s_gateway:1.8.2](https://ghcr.io/k8s-gateway/k8s_gateway)
- Row 2: **copy-from arm64**: [ghcr.io/k8s-gateway/k8s_gateway:1.8.2](https://ghcr.io/k8s-gateway/k8s_gateway)

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, CNPG PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

❌ means it is missing too.

- Row 1: **Dependency containers**: valkey ✅, postgresql (CNPG) ✅, k8s_gateway (k8sgatewayImage) ❌
- Row 2: **Dependency containers**: -
