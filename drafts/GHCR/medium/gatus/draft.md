# gatus

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: medium
- **Chart**: gatus
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: yes (postgresql, gatus-sidecar)
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/gatus
- **Source repository**: https://github.com/TwiN/gatus
- **Documentation**: https://gatus.io/docs
- **Website**: https://gatus.io

## Potentially relevant resources

- **Container image**: https://ghcr.io/home-operations/gatus-sidecar
- **Container image**: https://ghcr.io/twin/gatus
- **Source code repository**: https://github.com/home-operations/gatus-sidecar

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Single static Go binary built in a Go stage.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: none
- other: Go modules, static Go build

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8080/http (status page and API)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/gatus
- non-root: yes - no container override, common default runAsUser 568
- read-only-rootfs: yes - common default true; config is a configmap at /config/config.yaml and SQLite is under /config
- privileged: no - common default false, no override
- other-security: pod sysctl net.ipv4.ping_group_range "0 2147483647" (a safe sysctl); no capabilities, devices or hostPath
- extra-persistence: none beyond /config (configmap and optional sidecar pvc)
- confidence: high

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: the chart's gatus-sidecar has no ContainerForge app yet, so the sidecar must be dropped or built separately (spec).
- caveat: monitoring checks are defined in a YAML config file that the user must write to /config before the service does anything useful (spec).
- caveat: the upstream project ships no binaries, so both architectures are compiled from Go source (spec).

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: gatus
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/twin/gatus:v5.38.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/TwiN/gatus/blob/d255d0cd4d69ce818574cfdb3a7e82407e6559d7/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/TwiN/gatus)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Go service built as a single static binary; upstream ships no binaries, so compile it with a Go build stage and copy into /app. Config and sqlite data under /config; runs rootless trivially. The gatus-sidecar is a second small Go build.

### amd64 / arm64

How we get the application for that architecture.

- `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.

- **amd64**: compile
- **arm64**: compile

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/twin/gatus:v5.38.0](https://ghcr.io/twin/gatus)
- **copy-from arm64**: [ghcr.io/twin/gatus:v5.38.0](https://ghcr.io/twin/gatus)

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

❌ means it is missing too.

- **Dependency containers**: postgresql ✅, gatus-sidecar (sidecarImage) ❌
