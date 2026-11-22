# gonic

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: easy
- **Chart**: gonic
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/gonic
- **Source repository**: https://github.com/sentriz/gonic
- **Documentation**: https://github.com/sentriz/gonic/wiki

## Potentially relevant resources

- **Container image**: https://ghcr.io/sentriz/gonic

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Go single binary with prebuilt release files, so no runtime base is needed.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: none
- other: gonic release binary v0.23.0 (linux amd64/arm64)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 4747/http (web UI and subsonic API)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/gonic
- non-root: no - chart sets runAsNonRoot false, runAsUser 0, runAsGroup 0
- read-only-rootfs: yes - no readOnlyRootFilesystem override, so common true applies
- privileged: no - common default false, not overridden
- other-security: none in values
- extra-persistence: /data, /cache, /playlists, /podcast, /music (pvc, chart-defined; draft expects /config and read-only music, but chart mounts music without readOnly)
- confidence: high

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: gonic
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/sentriz/gonic:v0.23.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/sentriz/gonic/blob/v0.23.0/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/sentriz/gonic)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/sentriz/gonic/releases/download/v0.23.0/gonic-linux-amd64-v0.23.0) · [arm64](https://github.com/sentriz/gonic/releases/download/v0.23.0/gonic-linux-arm64-v0.23.0)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Gonic is a single Go binary with prebuilt linux amd64 and arm64 release files, so it drops onto containerforge-ubuntu with no compile. It runs as one process, with its database and cache in /config and the music library mounted read-only. No sibling is needed.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: no
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
