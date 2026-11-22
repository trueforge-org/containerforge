# netdata

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: hard
- **Chart**: netdata
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/netdata
- **Source repository**: https://github.com/netdata/netdata
- **Documentation**: https://learn.netdata.cloud/
- **Website**: https://www.netdata.cloud/

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: netdata
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/netdata/netdata:v2.13.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/netdata/netdata/blob/v2.13.0/packaging/docker/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/netdata/netdata)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/netdata/netdata/releases/download/v2.13.0/netdata-x86_64-latest.gz.run) · [arm64](https://github.com/netdata/netdata/releases/download/v2.13.0/netdata-aarch64-latest.gz.run)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: C monitoring agent with many plugins that read host /proc, /sys and cgroups and need host-level access. Upstream ships static gz.run installers for x86_64 and aarch64, but full host metrics need privileged or host namespace access, so it cannot run fully rootless.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/netdata/netdata:v2.13.0](https://ghcr.io/netdata/netdata)
- **copy-from arm64**: [ghcr.io/netdata/netdata:v2.13.0](https://ghcr.io/netdata/netdata)

### Dependency containers

- **Dependency containers**: none
