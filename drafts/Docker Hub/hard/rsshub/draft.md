# rsshub

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: rsshub
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/rsshub
- **Source repository**: https://github.com/browserless/chrome
- **Documentation**: https://docs.rsshub.app/

## Potentially relevant resources

- **Website**: https://docs.rsshub.app/en/install
- **Source code repository**: https://github.com/DIYgod/RSSHub
- **Container image**: https://hub.docker.com/r/browserless/chrome
- **Container image**: https://hub.docker.com/r/diygod/rsshub

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: `ghcr.io/trueforge-org/python-node`
- **Reason**: Node.js service driving a headless browser, so python-node provides the Node runtime.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: rsshub npm app (inferred), node runtime from python-node
- other: none (headless Chrome comes from the browserless sidecar base)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 1200/http (RSSHub web and feed API), 3000/http (browserless Chrome sidecar API)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/rsshub
- non-root: no - runAsUser 0, runAsNonRoot false, no override
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - not set in values (default false)
- other-security: none
- extra-persistence: none in values
- confidence: medium

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: browser-based routes need the browserless Chrome sidecar on port 3000; without it those feeds fail, so the sidecar must be deployed alongside (spec).
- caveat: the browserless sidecar needs extra shared memory and sandbox settings to run Chrome, which are not part of a plain RSSHub deployment (inferred).

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: rsshub
- **Role**: sidecar (browserlessImage)

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/browserless/chrome:1.61.1-chrome-stable`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/browserless/chrome/blob/2ebe1345023358d9006a3058b17dbfcc87347843/docker/chrome/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/browserless/chrome)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

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

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

- **Dependency containers**: -
