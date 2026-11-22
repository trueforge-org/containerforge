# bitcoin-node

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: easy
- **Chart**: bitcoin-node
- **Rows**: 1
- **Hard dependency containers**: no
- **Soft dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **Source repository**: https://github.com/bitcoin/bitcoin
- **Website**: https://bitcoincore.org

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: bitcoin-node
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/kylemanna/bitcoind:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/kylemanna/docker-bitcoind/blob/4b9eb11/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/bitcoin/bitcoin)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://bitcoincore.org/bin/bitcoin-core-32.1/bitcoin-32.1-x86_64-linux-gnu.tar.gz) · [arm64](https://bitcoincore.org/bin/bitcoin-core-32.1/bitcoin-32.1-aarch64-linux-gnu.tar.gz)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: bitcoind is shipped as official linux-gnu tarballs for x86_64 and aarch64, so we can unpack the 32.1 release into /app with its checksum check. It needs no services and runs rootless with the datadir on /config, though the chain data is large.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [kylemanna/bitcoind:latest](https://hub.docker.com/r/kylemanna/bitcoind)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
