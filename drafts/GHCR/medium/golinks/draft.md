# golinks

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: medium
- **Chart**: golinks
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/golinks
- **Source repository**: https://git.mills.io/prologic/golinks

## Potentially relevant resources

- **Container image**: https://ghcr.io/nicholaswilde/golinks
- **Source code repository**: https://github.com/nicholaswilde/docker-golinks
- **Source code repository**: https://github.com/prologic/golinks

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Single static Go binary built in a Go stage.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: none
- other: Go modules, go build from prologic/golinks source

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8080/http (web UI and redirects)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/golinks
- non-root: possible - chart sets runAsUser/runAsGroup 0 and runAsNonRoot false; simple Go binary can run unprivileged
- read-only-rootfs: possible - chart sets readOnlyRootFilesystem false; data is a pvc mount at /data
- privileged: no - common default false, no chart override
- other-security: none
- extra-persistence: /data (pvc, chart-level)
- confidence: medium

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: there are no release binaries, so the Go source must be compiled on both architectures (spec).
- caveat: short-link data is stored under /data, which must be mounted to survive restarts (spec).
- caveat: the chart tag is a short commit-style tag (version-154c581) that could not be matched to an upstream release (inferred).

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: golinks
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/nicholaswilde/golinks:version-154c581`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/nicholaswilde/docker-golinks/blob/bea20bc/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://git.mills.io/prologic/golinks)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Go URL shortener from prologic/golinks with no release binaries found, so build it with go build in a golang builder stage and copy it into /app. A simple static Go binary, but it needs a compile for both arches.

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
