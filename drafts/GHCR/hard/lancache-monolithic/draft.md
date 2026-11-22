# lancache-monolithic

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: hard
- **Chart**: lancache-monolithic
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/lancache-monolithic
- **Source repository**: https://github.com/tpill90/steam-lancache-prefill
- **Documentation**: https://lancache.net/docs

## Potentially relevant resources

- **Container image**: https://ghcr.io/ich777/lancache-prefill
- **Source code repository**: https://github.com/lancachenet/monolithic
- **Container image**: https://hub.docker.com/r/lancachenet/monolithic

## Base container

- **Foundation**: ubuntu (`ghcr.io/trueforge-org/ubuntu:26.4`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Self-contained .NET tool and shell scripts, which fit ubuntu.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: lancache-monolithic
- **Role**: sidecar (prefillImage)

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/ich777/lancache-prefill:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/ich777/docker-lancache-prefill/blob/master/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/tpill90/steam-lancache-prefill)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/tpill90/steam-lancache-prefill/releases/download/v3.0.0/SteamPrefill-3.0.0-linux-x64.zip) · [arm64](https://github.com/tpill90/steam-lancache-prefill/releases/download/v3.0.0/SteamPrefill-3.0.0-linux-arm64.zip)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Unraid-style image on ich777 base (cron, PUID/GID, root-oriented start scripts) that downloads SteamPrefill (.NET, self-contained) and others at runtime. Needs rework for rootless and read-only rootfs, plus cron scheduling and several prefill tools; no pinned upstream tag.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.
- A trailing `*` means the claim could not be confirmed against the upstream source, so it is a best judgement and should be rechecked before porting.

- **amd64**: yes*
- **arm64**: yes*

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [ghcr.io/ich777/lancache-prefill:latest](https://ghcr.io/ich777/lancache-prefill)
- **copy-from arm64**: no

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

- **Dependency containers**: -
