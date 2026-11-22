# czkawka

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: hard
- **Chart**: czkawka
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/czkawka
- **Source repository**: https://github.com/qarmin/czkawka

## Potentially relevant resources

- **Container image**: https://ghcr.io/jlesage/czkawka
- **Source code repository**: https://github.com/jlesage/docker-czkawka

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Rust binary built on ubuntu with no language runtime base.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: none
- other: release CLI binary (amd64 and arm64)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 5800/http (noVNC web desktop), 5900/tcp (VNC)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/czkawka
- non-root: no - chart forces runAsUser 0 and runAsNonRoot false (VNC or GUI base)
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - not set, default false
- other-security: capabilities add NET_BIND_SERVICE, KILL
- extra-persistence: /storage, /trash (type not set, likely pvc)
- confidence: high

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: czkawka
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/jlesage/czkawka:v26.09.2`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/jlesage/docker-czkawka/blob/v26.09.2/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/qarmin/czkawka)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/qarmin/czkawka/releases/download/12.0.2/linux_czkawka_cli_heif_raw_avif_x86_64) · [arm64](https://github.com/qarmin/czkawka/releases/download/12.0.2/linux_czkawka_cli_arm64)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Rust duplicate and similar-file finder with a GTK GUI and a CLI. The image builds it from the GitHub source archive in a build stage on a jlesage Alpine GUI base. The GUI needs VNC and a desktop, which makes it hard even though the Rust app itself is a ready binary.

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
