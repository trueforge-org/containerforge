# damselfly

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: damselfly
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/damselfly
- **Source repository**: https://github.com/Webreaper/Damselfly

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/webreaper/damselfly

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: .NET app built with dotnet publish.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: none
- other: .NET SDK for `dotnet publish` (arm64 must compile; amd64 can use Server-Dist-linux.zip 4.5.3)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 6363/http (web UI, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/damselfly
- non-root: no - runAsUser 0, runAsGroup 0
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - not set, common default false
- other-security: none in values
- extra-persistence: /pictures, /thumbs (chart persistence, type not shown; /config is the chart's own)
- confidence: medium

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: there is no release binary for arm64, so arm64 must compile with the .NET SDK, which makes the build slow.
- caveat: the app expects a PostgreSQL or other database sidecar, but none is listed as a dependency, so a database must be provided separately.
- caveat: the chart uses the rolling latest tag, so upstream changes reach the image without a version pin.

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: damselfly
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/webreaper/damselfly:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/Webreaper/Damselfly/blob/e110926104cc93d3c87a9617ba7ab4ae70dbb216/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/Webreaper/Damselfly)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/Webreaper/Damselfly/releases/download/4.5.3/Server-Dist-linux.zip)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: A .NET photo manager built from source with dotnet publish on top of an opaque webreaper/damselfly-base image that was not traced. Its base includes image and ML tooling, and it needs a PostgreSQL or database sidecar. No release binary exists, so both architectures must be compiled.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.
- `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.

- **amd64**: yes
- **arm64**: compile

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [webreaper/damselfly:latest](https://hub.docker.com/r/webreaper/damselfly)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
