# bitmagnet

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: easy
- **Chart**: bitmagnet
- **Rows**: 1
- **Hard dependency containers**: yes (postgresql)
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/bitmagnet
- **Source repository**: https://github.com/bitmagnet-io/bitmagnet
- **Documentation**: https://bitmagnet.io/
- **Website**: https://bitmagnet.io/

## Potentially relevant resources

- **Container image**: https://ghcr.io/bitmagnet-io/bitmagnet

## Base container

- **Foundation**: ubuntu (`ghcr.io/trueforge-org/ubuntu:26.4`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Go release binary run directly on ubuntu.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: bitmagnet
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/bitmagnet-io/bitmagnet:v0.10.1`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/bitmagnet-io/bitmagnet/blob/e31b30d7351c269dc801876f92ebc59d31fee545/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/bitmagnet-io/bitmagnet)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/bitmagnet-io/bitmagnet/releases/download/v0.10.0/bitmagnet_0.10.0_linux_amd64.apk) · [arm64](https://github.com/bitmagnet-io/bitmagnet/releases/download/v0.10.0/bitmagnet_0.10.0_linux_arm64.apk)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Go binary with embedded web UI, and upstream ships linux amd64 debs and arm64 tarballs, so ubuntu can reuse the release binary with no compile. The PostgreSQL database is external here, and it runs as one process.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: no
- **copy-from arm64**: no

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

- **Dependency containers**: postgresql ✅
