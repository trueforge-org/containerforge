# plexripper

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: plexripper
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/plexripper
- **Source repository**: https://github.com/Reaparr/Reaparr

## Potentially relevant resources

- **Source code repository**: https://github.com/PlexRipper/PlexRipper
- **Container image**: https://hub.docker.com/r/plexripper/plexripper

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: ASP.NET backend on the .NET runtime, added on ubuntu per the default rule; Node is only used in the build.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: bun (inferred) for frontend build
- other: .NET 8 SDK/runtime (ASP.NET 8) built from source

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8000/http (web UI and API, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/plexripper
- non-root: no - runAsUser 0, runAsGroup 0 in values
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - common default false, not overridden
- other-security: none
- extra-persistence: /Downloads (pvc default)
- confidence: medium

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: The draft has no published binary, so the image is compiled from source for both ASP.NET and the Bun/Nuxt frontend, which makes the build slow.
- caveat: The source link points to Reaparr/Reaparr while the image comes from PlexRipper/PlexRipper, so verify the correct upstream repo before pinning.
- caveat: A Plex account and token are required to connect to a Plex server (inferred).

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: plexripper
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/plexripper/plexripper:0.32.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/PlexRipper/PlexRipper/blob/20248f10085e6c99a83d8329ac271e7e1b31bb23/docker/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/Reaparr/Reaparr)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: ASP.NET 8 backend plus Bun/Nuxt frontend built from source in the upstream Dockerfile (version 0.32.0), then run on a dotnet runtime. Build both stages on containerforge-ubuntu, reusing the sonarr dotnet install pattern; keep config and downloads in /config and /tmp. Plex sibling exists.

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
