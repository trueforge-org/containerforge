# chromium

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR (linuxserver)
- **Difficulty**: hard
- **Chart**: chromium
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/chromium
- **Source repository**: https://chromium.googlesource.com/chromium/src
- **Documentation**: https://www.chromium.org/developers/
- **Website**: https://www.chromium.org/

## Potentially relevant resources

- **Container image**: https://ghcr.io/linuxserver/chromium
- **Source code repository**: https://github.com/linuxserver/docker-chromium
- **Website**: https://www.google.com/chrome

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Browser installed from a Debian or apt package on ubuntu.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: chromium (inferred; Ubuntu's package is a snap, so Debian repo or other source) | none
- python/pip: none | none
- node/npm: none | none
- other: none

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 3000/http (desktop web UI, inferred), 3001/https (desktop web UI, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/chromium
- non-root: no - chart sets runAsUser 0 and runAsGroup 0; draft keeps Selkies desktop base
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - not set in values; draft says browser sandbox may need privileges
- other-security: root, so common root caps added; /dev/shm covered by common default
- extra-persistence: /config/.cache (emptyDir, chart browsercache)
- confidence: medium

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: Ubuntu ships chromium as a snap, so the build depends on a Debian package source that may not match the Ubuntu base (inferred)
- caveat: the image tag is latest, a rolling tag, so browser versions change without notice (upstream status)
- caveat: a browser plus desktop stack is memory and CPU heavy, so size the limits for it (resource needs) (inferred)

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: chromium
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/linuxserver/chromium:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/linuxserver/docker-chromium/blob/4ec00555069627093b9110daff841d363f9a95f8/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://chromium.googlesource.com/chromium/src)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://www.chromium.org/getting-involved/download-chromium/)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Chromium browser installed with apt on a linuxserver selkies desktop base. Ubuntu's chromium is a snap, so the image needs the Debian package or another source. The browser sandbox needs flags or privileges for rootless, and the desktop stack makes it hard.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/linuxserver/chromium:latest](https://ghcr.io/linuxserver/chromium)
- **copy-from arm64**: [ghcr.io/linuxserver/chromium:latest](https://ghcr.io/linuxserver/chromium)

### Dependency containers

- **Dependency containers**: none
