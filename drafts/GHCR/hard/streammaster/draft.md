# streammaster

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: hard
- **Chart**: streammaster
- **Rows**: 1
- **Hard dependency containers**: yes (postgresql)
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/streammaster
- **Source repository**: https://github.com/carlreid/StreamMaster

## Potentially relevant resources

- **Website**: https://carlreid.github.io/StreamMaster
- **Container image**: https://ghcr.io/carlreid/streammaster

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: streammaster
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/carlreid/streammaster:0.15.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/carlreid/StreamMaster/blob/a8f8f6cda65138226ea2cfe73c5dd0db3a040c88/Dockerfile.template)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/carlreid/StreamMaster)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: ASP.NET 9 app published with dotnet, plus nginx and ffmpeg, from a generated Dockerfile. ContainerForge has no .NET runtime base, and the app runs several processes. It needs .NET runtime work plus rootless and read-only rework.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.
- A trailing `*` means the claim could not be confirmed against the upstream source, so it is a best judgement and should be rechecked before porting.

- **amd64**: yes*
- **arm64**: yes*

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/carlreid/streammaster:0.15.0](https://ghcr.io/carlreid/streammaster)
- **copy-from arm64**: [ghcr.io/carlreid/streammaster:0.15.0](https://ghcr.io/carlreid/streammaster)

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

- **Dependency containers**: postgresql ✅
