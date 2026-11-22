# vlmcsd-kms-server

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: easy
- **Chart**: vlmcsd-kms-server
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/vlmcsd-kms-server
- **Source repository**: https://github.com/Wind4/vlmcsd

## Potentially relevant resources

- **Source code repository**: https://github.com/mikolatero/docker-vlmcsd
- **Container image**: https://hub.docker.com/r/mikolatero/vlmcsd

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Single C daemon installed from apt or copied as a binary.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: vlmcsd
- python/pip: none
- node/npm: none
- other: alternative release binaries.tar.gz (svn1113)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 1688/tcp (KMS activation)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/vlmcsd-kms-server
- non-root: possible - chart sets runAsUser 0, but port 1688 is unprivileged and the daemon keeps no state
- read-only-rootfs: possible - chart sets false; draft has no writable state paths
- privileged: no - not set, common default false
- other-security: none
- extra-persistence: none
- confidence: high

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: KMS server only activates Windows and Office licences that are configured to use it; it is for licensed-volume environments and needs a reachable port 1688 (inferred).
- caveat: Draft uses an unpinned or svn-tagged binary bundle and Debian apt package; version drift between the two install paths is likely (inferred).

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: vlmcsd-kms-server
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/mikolatero/vlmcsd:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/mikolatero/docker-vlmcsd/blob/master/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/Wind4/vlmcsd)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/Wind4/vlmcsd/releases/download/svn1113/binaries.tar.gz)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: A single C KMS daemon with no config or state beyond the port. Install the Debian or Ubuntu vlmcsd package via apt, or copy the release binary into /app, and run it as apps on a high port, which fits the read-only rootfs rule.

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

- **Dependency containers**: none
