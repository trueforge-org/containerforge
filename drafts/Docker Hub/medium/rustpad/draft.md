# rustpad

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: rustpad
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/rustpad
- **Source repository**: https://github.com/ekzhang/rustpad

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/ekzhang/rustpad

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Rust server built with cargo on ubuntu, with node used only for the frontend build.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: cargo, rustc (inferred)
- python/pip: none
- node/npm: nodejs, npm (inferred) for frontend build
- other: crates from Cargo.lock (inferred)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 3030/http (web UI and websocket)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/rustpad
- non-root: no - runAsUser 0, runAsGroup 0 overrides
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - common default privileged false, not overridden
- other-security: none
- extra-persistence: /persist (pvc, chart storagedatabase; SQLite DB at /persist/rustpad_db.db)
- confidence: high

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: Collaborative pads are stored in a SQLite file under /persist, so that volume must be mounted and writable or pads are lost on restart.
- caveat: Output is a native binary, so the image is per-architecture and arm64 has not been tested.
- caveat: Build is heavy (Rust toolchain plus Node frontend build), so the first image build is slow and needs significant disk and RAM (inferred).

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: rustpad
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/ekzhang/rustpad:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/ekzhang/rustpad/blob/54e4a9383c84d7317af42a7ddb177ce8bcba058d/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/ekzhang/rustpad)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Rust server built with cargo plus a Node frontend build copied in as dist. Single process with no services, but it needs a Rust toolchain and node added to the build stage on containerforge-ubuntu. Output is a native binary, so the image is per-arch.

### amd64 / arm64

How we get the application for that architecture.

- `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.

- **amd64**: compile
- **arm64**: compile

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ekzhang/rustpad:latest](https://hub.docker.com/r/ekzhang/rustpad)
- **copy-from arm64**: [ekzhang/rustpad:latest](https://hub.docker.com/r/ekzhang/rustpad)

### Dependency containers

- **Dependency containers**: none
