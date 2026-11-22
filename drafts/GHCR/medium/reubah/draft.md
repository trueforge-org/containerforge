# reubah

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: medium
- **Chart**: reubah
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/reubah
- **Source repository**: https://github.com/DenDianUgerah/reubah

## Potentially relevant resources

- **Container image**: https://ghcr.io/dendianugerah/reubah
- **Source code repository**: https://github.com/dendianugerah/reubah

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Compiled Go binary with assets built in a stage.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: node + npm (inferred, build stage for assets)
- other: Go toolchain and Go modules

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8080/http (web UI, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/reubah
- non-root: yes - no securityContext override, common default runAsUser 568
- read-only-rootfs: yes - no override, common default true
- privileged: no - not set, common default false
- other-security: none
- extra-persistence: /app/tmp (emptyDir); /tmp is common and also emptyDir
- confidence: high

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: No release binary exists, so both amd64 and arm64 images are built from source with Go and npm at build time, which makes the build slow.
- caveat: The source tag is main, which is rolling, so builds are not reproducible unless the commit is pinned.
- caveat: Working files in /app/tmp are an emptyDir, so anything written there does not survive a pod or container restart (inferred).

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: reubah
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/dendianugerah/reubah:main`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/dendianugerah/reubah/blob/04469cf95ea7105f9d60e4906eab5533fb70ccd1/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/DenDianUgerah/reubah)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Go binary built with npm-built assets in a golang stage, then copied to alpine. Upstream has no release binary, so the Go module and npm build must run on ubuntu for both arches. It is a single process with no external services, so the work is the build.

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
