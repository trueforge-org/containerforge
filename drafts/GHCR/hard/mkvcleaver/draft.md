# mkvcleaver

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: hard
- **Chart**: mkvcleaver
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/mkvcleaver
- **Website**: https://blogs.sapib.ca/

## Potentially relevant resources

- **Container image**: https://ghcr.io/jlesage/mkvcleaver
- **Source code repository**: https://github.com/jlesage/docker-mkvcleaver

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Windows exe run under Wine, installed with apt on ubuntu.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: wine (inferred), xvfb (inferred)
- python/pip: none
- node/npm: none
- other: MKVCleaver Windows exe, AutoIt and MKVToolNix Windows archives (vendor downloads)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 5800/http (noVNC web UI), 5900/tcp (VNC)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/mkvcleaver
- non-root: no - chart sets runAsNonRoot false and runAsUser 0
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - not set in values
- other-security: capabilities add CHOWN, SETGID, SETUID, FOWNER, DAC_OVERRIDE, KILL, NET_BIND_SERVICE; disableS6Caps true
- extra-persistence: /storage (pvc chart default)
- confidence: high

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: mkvcleaver
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/jlesage/mkvcleaver:v26.09.1`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/jlesage/docker-mkvcleaver/blob/v26.09.1/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://blogs.sapib.ca/)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://blogs.sapib.ca/apps/download/d47a70b2339c4809edd842ebc45d2efc/MKVCleaver_x64_v0802.exe)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Windows-only MKVCleaver exe, AutoIt and MKVToolNix archives run under Wine on a jlesage GUI base over VNC. Wine, a GUI and a Windows-only binary make it hard. No native Linux build exists to reuse.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.
- `no`: neither works for that architecture, for example closed-source software where the vendor only ships an amd64 executable.

- **amd64**: yes
- **arm64**: no

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: no
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
