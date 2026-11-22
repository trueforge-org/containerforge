# fenrus

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: fenrus
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/fenrus
- **Source repository**: https://github.com/revenz/Fenrus

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/revenz/fenrus

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: ASP.NET dashboard built with dotnet, so ubuntu provides dotnet.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: dotnet-sdk-10.0, aspnetcore-runtime-10.0 (inferred)
- python/pip: none
- node/npm: none
- other: .NET 10 SDK (build from source)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 3000/http (web UI, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/fenrus
- non-root: no - chart sets container runAsUser 0 and runAsGroup 0
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - common default false, no override in values
- other-security: none beyond root override
- extra-persistence: /app/data (pvc, data); /app/wwwroot/images (pvc, images)
- confidence: high

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: The ASP.NET 10 app is compiled from source, so the first build is slow and needs enough RAM and disk for the .NET SDK (inferred).
- caveat: Initial dashboard setup is done in the web UI (manual setup, inferred).
- caveat: The draft says the Dockerfile copies a prebuilt build folder, so the build must be redone cleanly on both architectures.

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: fenrus
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/revenz/fenrus:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/revenz/Fenrus/blob/fc8f57ac9d5643d16f7d8427f8341397e645f501/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/revenz/Fenrus)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: ASP.NET 10 dashboard built from source with dotnet, so the SDK or runtime must be added on ubuntu. The Dockerfile copies a prebuilt build folder, so a clean build is needed. Keep the database under /config and run rootless.

### amd64 / arm64

How we get the application for that architecture.

- `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.

- **amd64**: compile
- **arm64**: compile

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [revenz/fenrus:latest](https://hub.docker.com/r/revenz/fenrus)
- **copy-from arm64**: [revenz/fenrus:latest](https://hub.docker.com/r/revenz/fenrus)

### Dependency containers

- **Dependency containers**: none
