# nebula-sync

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: easy
- **Chart**: nebula-sync
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/nebula-sync
- **Source repository**: https://github.com/lovelaze/nebula-sync
- **Documentation**: https://github.com/lovelaze/nebula-sync/blob/main/README.md

## Potentially relevant resources

- **Container image**: https://ghcr.io/lovelaze/nebula-sync

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Go binary shipped in release tarballs.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: none
- other: release tarball (nebula-sync_0.11.3_linux_<arch>.tar.gz)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: none (inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/nebula-sync
- non-root: yes - no securityContext override, common runAsUser 568; single Go binary
- read-only-rootfs: yes - common default readOnlyRootFilesystem true; state is only in /tmp or /config
- privileged: no - no privileged key in values; common default false
- other-security: none
- extra-persistence: none
- confidence: high

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: nebula-sync
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/lovelaze/nebula-sync:v0.11.3`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/lovelaze/nebula-sync/blob/v0.11.3/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/lovelaze/nebula-sync)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/lovelaze/nebula-sync/releases/download/v0.11.3/nebula-sync_0.11.3_linux_amd64.tar.gz) · [arm64](https://github.com/lovelaze/nebula-sync/releases/download/v0.11.3/nebula-sync_0.11.3_linux_arm64.tar.gz)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Go binary from the lovelaze/nebula-sync release, copied into /app. Upstream builds linux amd64 and arm64 tarballs, and the app runs as one process with no extra services, rootless, with state only in /tmp or /config.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/lovelaze/nebula-sync:v0.11.3](https://ghcr.io/lovelaze/nebula-sync)
- **copy-from arm64**: [ghcr.io/lovelaze/nebula-sync:v0.11.3](https://ghcr.io/lovelaze/nebula-sync)

### Dependency containers

- **Dependency containers**: none
