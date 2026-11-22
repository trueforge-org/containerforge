# birdnet-go

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: hard
- **Chart**: birdnet-go
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/birdnet-go
- **Source repository**: https://github.com/tphakala/birdnet-go
- **Documentation**: https://github.com/tphakala/birdnet-go/wiki

## Potentially relevant resources

- **Container image**: https://ghcr.io/tphakala/birdnet-go

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Go binary in release tarballs.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: alsa-utils, libasound2 (inferred, audio capture)
- python/pip: none
- node/npm: none
- other: release tarball linux-amd64 / linux-arm64

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8080/http (web UI, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/birdnet-go
- non-root: yes - no securityContext override, defaults 568 apply
- read-only-rootfs: yes - default readOnlyRootFilesystem true, no override
- privileged: no - not set, default false
- other-security: none in values; audio capture device (ALSA or USB mic) from the Reason is not shown, so device or group access is unconfirmed
- extra-persistence: /data (type not set, likely pvc)
- confidence: medium

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: birdnet-go
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/tphakala/birdnet-go:20261031`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/tphakala/birdnet-go/blob/bc1e0de67d9a2292b4742a79f868a7720f8e6a12/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/tphakala/birdnet-go)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/tphakala/birdnet-go/releases/download/20261031/birdnet-go-linux-amd64-20261031.tar.gz) · [arm64](https://github.com/tphakala/birdnet-go/releases/download/20261031/birdnet-go-linux-arm64-20261031.tar.gz)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Go binary with TFLite models that needs a live audio capture device (ALSA or USB microphone), so hardware access makes it hard even though the release tarballs exist. Upstream ships a linux-amd64 and linux-arm64 tarball, so packaging is simple and runtime access is the blocker.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/tphakala/birdnet-go:20261031](https://ghcr.io/tphakala/birdnet-go)
- **copy-from arm64**: [ghcr.io/tphakala/birdnet-go:20261031](https://ghcr.io/tphakala/birdnet-go)

### Dependency containers

- **Dependency containers**: none
