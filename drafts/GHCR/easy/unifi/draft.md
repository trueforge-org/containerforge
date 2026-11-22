# unifi

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: easy
- **Chart**: unifi
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/unifi
- **Website**: https://ui.com/

## Potentially relevant resources

- **Container image**: https://ghcr.io/goofball222/unifi
- **Source code repository**: https://github.com/jacobalberty/unifi-docker
- **Website**: https://unifi-network.ui.com

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [java17](https://github.com/trueforge-org/containerforge/tree/main/apps/java17) (`ghcr.io/trueforge-org/java17`)
- **Reason**: Java app with no version named, so java17 is used by default.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: none
- other: UniFi vendor .deb (dpkg install), java17 sibling runtime; mongodb and unifi-network-application siblings

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: unifi
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/goofball222/unifi:10.6.109`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/goofball222/unifi/blob/ae54167b930b/10.6/official/Dockerfile.debian)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://ui.com/)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://dl.ui.com/unifi/10.6.109/unifi_sysvinit_all.deb)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: UniFi Network Application from the vendor .deb (Java app). ContainerForge already has unifi-network-application (amd64 and arm64) and mongodb as siblings, so reuse them and wire the chart configuration to them. Main work is config mapping, not a new build.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.
- A trailing `*` means the claim could not be confirmed against the upstream source, so it is a best judgement and should be rechecked before porting.

- **amd64**: yes*
- **arm64**: yes*

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [ghcr.io/goofball222/unifi:10.6.109](https://ghcr.io/goofball222/unifi)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
