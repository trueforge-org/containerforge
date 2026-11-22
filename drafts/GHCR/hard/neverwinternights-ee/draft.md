# neverwinternights-ee

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: hard
- **Chart**: neverwinternights-ee
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/neverwinternights-ee
- **Website**: https://store.steampowered.com/app/704450/
- **Website**: https://www.beamdog.com/

## Potentially relevant resources

- **Container image**: https://ghcr.io/ich777/nwnee-server
- **Website**: https://www.beamdog.com/games/neverwinter-nights-enhanced

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Closed-source native server that needs i386 libraries, so ubuntu fits.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: libc6:i386, libstdc++6:i386 (inferred, i386 multiarch), libsndio .deb workaround (inferred)
- python/pip: none
- node/npm: none
- other: Beamdog NWN:EE server files fetched at runtime (vendor download, amd64 only)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 5121/udp (game, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/neverwinternights-ee
- non-root: no - chart sets runAsUser 0 and runAsGroup 0
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - not set in values
- other-security: none in values; UDP 5121 game port
- extra-persistence: /nwnee (serverfiles, pvc chart default)
- confidence: high

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: neverwinternights-ee
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/ich777/nwnee-server:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/ich777/docker-nwnee/blob/master/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://store.steampowered.com/app/704450/)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Closed-source Beamdog NWN:EE server fetched at runtime. It is x86 only, needs i386 libraries and a libsndio .deb workaround, and the image runs as root. Closed source with a vendor-only download and the multi-arch gap make it hard.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.
- `no`: neither works for that architecture, for example closed-source software where the vendor only ships an amd64 executable.
- A trailing `*` means the claim could not be confirmed against the upstream source, so it is a best judgement and should be rechecked before porting.

- **amd64**: yes*
- **arm64**: no*

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [ghcr.io/ich777/nwnee-server:latest](https://ghcr.io/ich777/nwnee-server)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
