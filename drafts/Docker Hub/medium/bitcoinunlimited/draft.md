# bitcoinunlimited

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: bitcoinunlimited
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/bitcoinunlimited
- **Source repository**: https://github.com/BitcoinUnlimited/BitcoinUnlimited
- **Website**: https://www.bitcoinunlimited.info/

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/amacneil/bitcoinunlimited

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: bitcoinunlimited
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/amacneil/bitcoinunlimited:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/amacneil/docker-bitcoin/blob/master/unlimited/1.1.1.1/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/BitcoinUnlimited/BitcoinUnlimited)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Bitcoin Unlimited full node. The image is a 2018 build on debian stretch, and no release assets were located for the BCHunlimited1.9.0.1 tag. Building the C++ node from source is long but standard, and chain data must go to /config.

### amd64 / arm64

How we get the application for that architecture.

- `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.

- **amd64**: compile
- **arm64**: compile

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [amacneil/bitcoinunlimited:latest](https://hub.docker.com/r/amacneil/bitcoinunlimited)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
