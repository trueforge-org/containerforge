# hexchat

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Quay
- **Difficulty**: hard
- **Chart**: hexchat
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/hexchat
- **Source repository**: https://github.com/hexchat/hexchat
- **Documentation**: https://hexchat.readthedocs.io/

## Potentially relevant resources

- **Source code repository**: https://github.com/binhex/documentation
- **Website**: https://hexchat.github.io
- **Container image**: https://quay.io/binhex/arch-hexchat
- **Container image**: https://registry.hub.docker.com/r/binhex/arch-hexchat

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Desktop IRC client installed from the Ubuntu archive.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: hexchat
- python/pip: none
- node/npm: none
- other: none

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 6080/http (noVNC desktop web UI, inferred), 5900/tcp (VNC, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/hexchat
- non-root: no - chart sets runAsUser 0, runAsGroup 0
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - not set, common default false
- other-security: none in values; VNC-style web desktop on port 6080
- extra-persistence: none beyond chart's /config
- confidence: medium

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: hexchat
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `quay.io/binhex/arch-hexchat:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/binhex/arch-hexchat/blob/2c35dde8b489a4cfec0ffbd3118c6166fb11516a/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/hexchat/hexchat)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: binary: `apt:hexchat`

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: IRC GTK client on a binhex Arch desktop base, so a desktop/VNC image needing a display session. Ubuntu archive has hexchat for both arches, so the package is easy and the GUI session setup is the effort driver.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [quay.io/binhex/arch-hexchat:latest](https://quay.io/repository/binhex/arch-hexchat)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
