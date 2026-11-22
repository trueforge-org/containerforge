# rapidphotodownloader

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: hard
- **Chart**: rapidphotodownloader
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/rapidphotodownloader
- **Source repository**: https://github.com/damonlynch/rapid-photo-downloader
- **Documentation**: https://damonlynch.net/rapid/documentation

## Potentially relevant resources

- **Container image**: https://ghcr.io/ich777/rapidphotodownloader
- **Website**: https://www.damonlynch.net/rapid

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Alternative runtime image**: [python](https://github.com/trueforge-org/containerforge/tree/main/apps/python) (`ghcr.io/trueforge-org/python`)
- **Reason**: Python desktop app installed via apt, so the distro provides Python too.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: rapid-photo-downloader, python3-pyqt5 (inferred), exiv2 (inferred), novnc (inferred), fluxbox (inferred), xvfb (inferred)
- python/pip: none (python supplied by apt)
- node/npm: none
- other: none

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8080/http (noVNC web UI, inferred), 5900/tcp (VNC, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/rapidphotodownloader
- non-root: no - chart sets runAsUser 0 and runAsGroup 0
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - not set in values
- other-security: none in values
- extra-persistence: /rapidphotodownloader (datadir, pvc chart default); /media/destination (destinantionfolder, pvc chart default); /media/source (sourcefolder, pvc chart default)
- confidence: high

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: rapidphotodownloader
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/ich777/rapidphotodownloader:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/ich777/docker-rapidphotodownloader/blob/master/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/damonlynch/rapid-photo-downloader)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: binary: `apt:rapid-photo-downloader`

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Rapid Photo Downloader is a Python/PyQt desktop app run through noVNC and fluxbox. The GUI stack and the rootless rework needed for a read-only rootfs put it in the hard band, even though the core is pure Python.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [ghcr.io/ich777/rapidphotodownloader:latest](https://ghcr.io/ich777/rapidphotodownloader)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
