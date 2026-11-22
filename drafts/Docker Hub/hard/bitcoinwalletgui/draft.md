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

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Official daemon and GUI binaries running on a VNC desktop.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: xfce4 desktop, VNC server such as tigervnc-standalone-server (inferred)
- python/pip: none
- node/npm: none
- other: bitcoin-core 32.1 tarball from bitcoincore.org (amd64, arm64)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8333/tcp (bitcoin P2P, inferred), 6080/http (noVNC web, inferred), 5900/tcp (VNC, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/bitcoinwalletgui
- non-root: possible - chart sets runAsUser 0; VNC desktop stack would need rework
- read-only-rootfs: possible - chart sets false; desktop writes to home paths
- privileged: no - not set, common default false
- other-security: none
- extra-persistence: /headless/.bitcoin/ (pvc, blockchain data, large; chart mount)
- confidence: medium

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
