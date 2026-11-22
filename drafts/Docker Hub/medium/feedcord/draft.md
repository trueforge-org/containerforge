# feedcord

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: feedcord
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/feedcord
- **Source repository**: https://github.com/Qolors/FeedCord

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/qolors/feedcord

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: .NET 9 app with the dotnet runtime from ubuntu apt.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: dotnet-runtime-9.0 (inferred)
- python/pip: none
- node/npm: none
- other: .NET 9 SDK for dotnet publish at build (inferred)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: none

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/feedcord
- non-root: yes - no runAs override, common default runAsUser 568
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - common default false, no override in values
- other-security: none (common drop ALL, seccomp RuntimeDefault)
- extra-persistence: none data path; configmap file mounted at /app/config/appsettings.json (read-only)
- confidence: medium

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: The app needs a Discord bot token or webhook and RSS feed definitions before it posts anything (external service, inferred).
- caveat: The config file is mounted read-only from a ConfigMap at /app/config/appsettings.json, so any write-back by the app would fail (inferred).
- caveat: .NET 9 runtime and SDK must come from apt or Microsoft; the ubuntu base version must provide them (inferred).

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: feedcord
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `qolors/feedcord:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/Qolors/FeedCord/blob/c9568b968505c2979b5123f9d84262fe0d65dd85/FeedCord/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/Qolors/FeedCord)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: .NET 9 app built with dotnet publish and run on the aspnet runtime; ContainerForge has no .NET base so the port needs the dotnet runtime from Ubuntu apt or Microsoft tarball. Config under /config.

### amd64 / arm64

How we get the application for that architecture.

- `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.

- **amd64**: compile
- **arm64**: compile

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [qolors/feedcord:latest](https://hub.docker.com/r/qolors/feedcord)
- **copy-from arm64**: [qolors/feedcord:latest](https://hub.docker.com/r/qolors/feedcord)

### Dependency containers

- **Dependency containers**: none
