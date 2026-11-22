# backrest

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: easy
- **Chart**: backrest
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/backrest
- **Source repository**: https://github.com/garethgeorge/backrest
- **Documentation**: https://garethgeorge.github.io/backrest/introduction/getting-started
- **Website**: https://garethgeorge.github.io/backrest/

## Potentially relevant resources

- **Container image**: https://ghcr.io/garethgeorge/backrest

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Go release binaries run directly on ubuntu.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: none
- other: backrest release tarball; restic release binary

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 9898/http (web UI and API)

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: backrest
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/garethgeorge/backrest:v1.14.1`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/garethgeorge/backrest/blob/875c9cb51e626a75276a64da42c6a9ec0695010a/Dockerfile.alpine)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/garethgeorge/backrest)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/garethgeorge/backrest/releases/download/v1.14.1/backrest_Linux_x86_64.tar.gz) · [arm64](https://github.com/garethgeorge/backrest/releases/download/v1.14.1/backrest_Linux_arm64.tar.gz)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Go binary from the goreleaser release, with restic bundled, run as one process. Use the upstream release tarballs for backrest and restic on containerforge-ubuntu, and keep repo config and cache under /config and /tmp. Little beyond pinning two release binaries.

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
