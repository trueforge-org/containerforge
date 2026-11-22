# sia-daemon

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: medium
- **Chart**: sia-daemon
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/sia-daemon
- **Source repository**: https://github.com/SiaFoundation/siad
- **Documentation**: https://docs.sia.tech/
- **Website**: https://sia.tech

## Potentially relevant resources

- **Container image**: https://ghcr.io/siafoundation/siad
- **Source code repository**: https://github.com/SiaFoundation/siad/pkgs/container/siad
- **Source code repository**: https://github.com/siafoundation/siad

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Go daemon built from source into a binary.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: none
- other: Go toolchain (golang build from source)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 9980/http (API), 9981/tcp (gateway, inferred), 9982/tcp (host, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/sia-daemon
- non-root: no - container override runAsUser 0, runAsGroup 0
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - not set, common default false
- other-security: none
- extra-persistence: none beyond chart's own datadirectory at /sia-data
- confidence: high

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: Upstream siad is a legacy daemon and has been superseded by newer Sia daemons, so long-term support is a concern (inferred).
- caveat: A wallet seed must be created or imported through the API or UI on first run, which is a manual step (inferred).
- caveat: Initial blockchain sync can take a long time and a lot of disk (inferred).

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: sia-daemon
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/siafoundation/siad:master`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/SiaFoundation/siad/blob/66e7fc6/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/SiaFoundation/siad)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: siad is an older Go daemon with no Linux release binaries for the daemon itself, so it has to be built from source with golang. It is one process with its API on a port and wallet and config data that must move to /config. The build is modest and the runtime is simple.

### amd64 / arm64

How we get the application for that architecture.

- `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.

- **amd64**: compile
- **arm64**: compile

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: no
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
