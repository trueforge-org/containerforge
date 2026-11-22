# openobserve

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Other registries
- **Difficulty**: easy
- **Chart**: openobserve
- **Rows**: 1
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: openobserve
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `public.ecr.aws/zinclabs/openobserve:v1.1.2`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/openobserve/openobserve/blob/d16d693ba99bc20621a58b948ecbcad7ec7fa882/deploy/build/Dockerfile.tag.amd64)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/openobserve/openobserve)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://downloads.openobserve.ai/releases/openobserve/v1.1.2/openobserve-v1.1.2-linux-amd64.tar.gz) · [arm64](https://downloads.openobserve.ai/releases/openobserve/v1.1.2/openobserve-v1.1.2-linux-arm64.tar.gz)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Rust single binary with embedded UI, shipped as a prebuilt tarball. Download per arch into /app, data directory set to /config; the upstream image is distroless, so glibc Ubuntu base is fine and it runs rootless.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [public.ecr.aws/zinclabs/openobserve:v1.1.2](https://gallery.ecr.aws/zinclabs/openobserve)
- **copy-from arm64**: [public.ecr.aws/zinclabs/openobserve:v1.1.2](https://gallery.ecr.aws/zinclabs/openobserve)

### Dependency containers

- **Dependency containers**: none
