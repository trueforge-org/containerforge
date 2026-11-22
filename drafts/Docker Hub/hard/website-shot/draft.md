# website-shot

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: website-shot
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/website-shot
- **Source repository**: https://github.com/Flowko/website-shot

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/flowko1/website-shot

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: `ghcr.io/trueforge-org/python-node`
- **Reason**: Node app built with yarn on the Node runtime, so python-node fits.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: chromium (inferred, Ubuntu ships it as snap so another source is needed)
- python/pip: none
- node/npm: yarn, puppeteer (inferred), repo npm deps
- other: headless Chromium binary from a non-snap source (inferred), git clone of Flowko/website-shot

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 3000/http (inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/website-shot
- non-root: yes - chart sets runAsUser 1000, runAsGroup 1000
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - default false, no override
- other-security: none (Chromium needs writable /tmp, which the common defaults cover)
- extra-persistence: /usr/src/website-shot/screenshots (pvc)
- confidence: medium

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: Ubuntu ships Chromium as a snap, so a Chromium binary from another source must be installed, and it must match the puppeteer version (inferred)
- caveat: headless Chromium is memory-hungry, so the container needs enough RAM for each screenshot job (inferred)
- caveat: the app is Nuxt 2 with an old puppeteer, so the npm dependency tree may fail to install on newer Node versions (inferred)

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: website-shot
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/flowko1/website-shot:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/Flowko/website-shot/blob/72076a845f18d38522b696fd080dac3eda3cd781/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/Flowko/website-shot)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Nuxt 2 app built with yarn on the node sibling, with an old puppeteer needing a headless Chromium. Ubuntu ships chromium as a snap, so amd64 and arm64 both need another Chromium source. Runs as one process with scratch under /tmp.

### amd64 / arm64

How we get the application for that architecture.

- `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.

- **amd64**: compile
- **arm64**: compile

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: no
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
