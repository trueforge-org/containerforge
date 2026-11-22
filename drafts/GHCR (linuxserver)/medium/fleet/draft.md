# fleet

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR (linuxserver)
- **Difficulty**: medium
- **Chart**: fleet
- **Rows**: 1
- **Hard dependency containers**: yes (mariadb)
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/fleet
- **Source repository**: https://github.com/linuxserver/fleet
- **Documentation**: https://fleetdm.com/docs
- **Website**: https://fleetdm.com/

## Potentially relevant resources

- **Container image**: https://ghcr.io/linuxserver/fleet

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [java17](https://github.com/trueforge-org/containerforge/tree/main/apps/java17) (`ghcr.io/trueforge-org/java17`)
- **Alternative runtime image**: [java21](https://github.com/trueforge-org/containerforge/tree/main/apps/java21) (`ghcr.io/trueforge-org/java21`)
- **Reason**: Single jar that the draft allows on java17 or java21, and java17 is picked as the default.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: fleet
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/linuxserver/fleet:2.3.3`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/linuxserver/docker-fleet/blob/68995eabc52afa0c3a1fddf3c5dbc803d6943c36/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/linuxserver/fleet)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/linuxserver/fleet/releases/download/2.3.3/fleet-2.3.3.jar)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Java application shipped as one fleet-2.3.3.jar release asset. Run it on the ContainerForge java17 or java21 base with the jar copied into /app and data in /config. Bytecode is arch-neutral, so the main effort is choosing the right Java version.

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

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

- **Dependency containers**: mariadb ✅
