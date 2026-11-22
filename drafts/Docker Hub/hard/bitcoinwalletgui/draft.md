# bitcoinwalletgui

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: bitcoinwalletgui
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/bitcoinwalletgui
- **Source repository**: https://github.com/bitcoin/bitcoin
- **Documentation**: https://bitcoincore.org/en/doc/
- **Website**: https://bitcoincore.org/

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/ulisses1478/bitcoinwallet-gui

## Base container

- **Primary**: ubuntu
- **Alternative**: none
- **Reason**: Official daemon and GUI binaries running on a VNC desktop.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: bitcoinwalletgui
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/ulisses1478/bitcoinwallet-gui:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

`-` means no public Dockerfile could be found.

- **Dockerfile**: -

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/bitcoin/bitcoin)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://bitcoincore.org/bin/bitcoin-core-32.1/bitcoin-32.1-x86_64-linux-gnu.tar.gz) · [arm64](https://bitcoincore.org/bin/bitcoin-core-32.1/bitcoin-32.1-aarch64-linux-gnu.tar.gz)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Ubuntu VNC container with a bitcoin wallet GUI, so it needs a desktop and VNC stack. The bitcoin daemon and GUI are official binaries for both architectures. No public Dockerfile was found, so the setup must be rebuilt from scratch.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [ulisses1478/bitcoinwallet-gui:latest](https://hub.docker.com/r/ulisses1478/bitcoinwallet-gui)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
