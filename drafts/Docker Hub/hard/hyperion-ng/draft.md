# hyperion-ng

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: hyperion-ng
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/hyperion-ng
- **Source repository**: https://github.com/hyperion-project/hyperion.ng
- **Documentation**: https://docs.hyperion-project.org
- **Website**: https://hyperion-project.org/

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/sirfragalot/hyperion.ng

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: C++ app installed from release .deb packages.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: Hyperion release .deb installed via dpkg, deps resolved by apt (inferred)
- python/pip: none
- node/npm: none
- other: Hyperion 2.2.0 .deb per arch from release

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: hyperion-ng
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/sirfragalot/hyperion.ng:2.2.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

`-` means no public Dockerfile could be found.

- **Dockerfile**: -

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/hyperion-project/hyperion.ng)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/hyperion-project/hyperion.ng/releases/download/2.2.0/Hyperion-2.2.0-Linux-amd64.deb) · [arm64](https://github.com/hyperion-project/hyperion.ng/releases/download/2.2.0/Hyperion-2.2.0-Linux-arm64.deb)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: No Dockerfile exists at the tag, and the Hub page links none. Hyperion drives USB and hardware LED devices, so it needs host hardware access that a rootless image cannot provide. Release tarballs exist for both arches.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [sirfragalot/hyperion.ng:2.2.0](https://hub.docker.com/r/sirfragalot/hyperion.ng)
- **copy-from arm64**: [sirfragalot/hyperion.ng:2.2.0](https://hub.docker.com/r/sirfragalot/hyperion.ng)

### Dependency containers

- **Dependency containers**: none
