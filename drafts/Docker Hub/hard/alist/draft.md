# alist

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: alist
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/alist
- **Source repository**: https://github.com/AlistGo/alist
- **Documentation**: https://alistgo.com/guide/
- **Website**: https://alistgo.com/

## Potentially relevant resources

- **Source code repository**: https://github.com/Xhofe/alist
- **Container image**: https://hub.docker.com/r/xhofe/alist-aria2

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Release binary plus aria2 from apt, with no language runtime.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: aria2
- python/pip: none
- node/npm: none
- other: alist release tarball v3.41.0 (amd64, arm64)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 5244/http (web UI and API)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/alist
- non-root: possible - chart sets runAsUser 0; release binary can run unprivileged, but aria2 in the same image needs a supervisor split
- read-only-rootfs: possible - chart sets false; draft says read-only needs supervisor rework
- privileged: no - not set, common default false
- other-security: aria2 sub-service enabled in chart (port 6800)
- extra-persistence: /opt/alist/data (pvc) unless moved under /config
- confidence: medium

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: The image bundles aria2 with alist, so two services run together and the aria2 RPC secret must be set or it stays open on port 6800 (inferred).
- caveat: Upstream tags move; the draft pins v3.41.0, so re-verify the release tarball URL on each version bump.

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: alist
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/xhofe/alist-aria2:v3.41.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/AlistGo/with_aria2/blob/12a215e1e1b1375f0512d4e2e310a35a4209e4de/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/AlistGo/alist)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/AlistGo/alist/releases/download/v3.41.0/alist-linux-amd64.tar.gz) · [arm64](https://github.com/AlistGo/alist/releases/download/v3.41.0/alist-linux-arm64.tar.gz)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Wrapper on xhofe/alist that adds aria2 through an install script, so the image runs alist and aria2 together as several services. Rootless and read-only operation needs a process split or supervisor rework. The alist release binaries exist for both architectures.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [xhofe/alist-aria2:v3.41.0](https://hub.docker.com/r/xhofe/alist-aria2)
- **copy-from arm64**: [xhofe/alist-aria2:v3.41.0](https://hub.docker.com/r/xhofe/alist-aria2)

### Dependency containers

- **Dependency containers**: none
