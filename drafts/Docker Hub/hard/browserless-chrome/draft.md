# browserless-chrome

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: browserless-chrome
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/browserless-chrome
- **Source repository**: https://github.com/browserless/chrome
- **Documentation**: https://docs.browserless.io/

## Potentially relevant resources

- **Website**: https://docs.browserless.io/docs/docker.html
- **Container image**: https://hub.docker.com/r/browserless/chrome

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: `ghcr.io/trueforge-org/python-node`
- **Reason**: Node.js service that drives headless Chromium.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: chrome runtime libs such as libnss3, libgbm1, libasound2t64, fonts-liberation (inferred)
- python/pip: none
- node/npm: browserless app deps (inferred)
- other: Chrome stable .deb from vendor (not snap chromium)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 3000/http (browser API and debugger)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/browserless-chrome
- non-root: yes - no securityContext override, runAsUser 568 default
- read-only-rootfs: yes - default readOnlyRootFilesystem true; Chrome writes to /tmp, /dev/shm and /downloads
- privileged: no - not set, common default false
- other-security: none in values; Chrome sandbox flags not set (draft notes sandbox handling needed)
- extra-persistence: /downloads (pvc) and /metrics (pvc), both chart mounts
- confidence: medium

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: browserless-chrome
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/browserless/chrome:1.61.1-chrome-stable, 1.61.1-puppeteer-13.1.3`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/browserless/chrome/blob/2ebe1345023358d9006a3058b17dbfcc87347843/docker/chrome/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/browserless/chrome)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/browserless/chrome/releases)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Node.js service that drives headless Chromium on the ghcr browserless base, with many Chrome runtime libraries, fonts and sandbox settings. Chrome needs root-free sandbox handling and extra shared memory, so this is hard even though the Node app itself copies cleanly.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [browserless/chrome:1.61.1-chrome-stable](https://hub.docker.com/r/browserless/chrome)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
