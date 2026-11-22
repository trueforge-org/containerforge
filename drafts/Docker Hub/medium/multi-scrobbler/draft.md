# multi-scrobbler

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: multi-scrobbler
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/multi-scrobbler
- **Source repository**: https://github.com/FoxxMD/multi-scrobbler
- **Documentation**: https://foxxmd.github.io/multi-scrobbler/configuration/

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/foxxmd/multi-scrobbler

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: `ghcr.io/trueforge-org/python-node`
- **Reason**: TypeScript Node app built in a build stage, so python-node provides node.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: npm deps and TypeScript build (inferred)
- other: multi-scrobbler source at tag 0.21.1

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 9078/http (web UI and API)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/multi-scrobbler
- non-root: possible - chart forces runAsUser 0 and runAsNonRoot false
- read-only-rootfs: possible - chart sets readOnlyRootFilesystem false
- privileged: no - common default, not overridden
- other-security: none
- extra-persistence: none beyond /config
- confidence: medium

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: each source (Spotify, Last.fm, Plex, Jellyfin and similar) needs its own account or token configured before scrobbling works (inferred).
- caveat: the pinned tag 0.21.1 will not pick up newer upstream releases until the draft changes (from draft).
- caveat: the app writes its config and tokens to a state path that must be persisted (inferred).

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: multi-scrobbler
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/foxxmd/multi-scrobbler:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/FoxxMD/multi-scrobbler/blob/d164f568a47874e7a8d33604db630e6edbfdcca6/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/FoxxMD/multi-scrobbler)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/FoxxMD/multi-scrobbler/releases/tag/0.21.1)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: TypeScript Node app compiled in a node builder stage and run from a distroless nodejs image. Port it to the ContainerForge node base with a build step, keeping config and state in /config and temp data in /tmp. One process.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [foxxmd/multi-scrobbler:latest](https://hub.docker.com/r/foxxmd/multi-scrobbler)
- **copy-from arm64**: [foxxmd/multi-scrobbler:latest](https://hub.docker.com/r/foxxmd/multi-scrobbler)

### Dependency containers

- **Dependency containers**: none
