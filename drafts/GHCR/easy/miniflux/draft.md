# miniflux

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: easy
- **Chart**: miniflux
- **Rows**: 1
- **Hard dependency containers**: yes (postgresql)
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/miniflux
- **Source repository**: https://github.com/miniflux/v2
- **Documentation**: https://miniflux.app/docs/

## Potentially relevant resources

- **Container image**: https://ghcr.io/miniflux/miniflux

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Go binary with release builds for amd64 and arm64.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: miniflux
- python/pip: none
- node/npm: none
- other: none

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8080/http (web UI)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/miniflux
- non-root: yes - no securityContext override, common runAsUser 568; Go binary with external PostgreSQL
- read-only-rootfs: yes - common default readOnlyRootFilesystem true; no local state
- privileged: no - no privileged key in values; common default false
- other-security: none
- extra-persistence: none (chart's /config is the chart's own)
- confidence: high

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: needs an external PostgreSQL server; the container does not start usefully without one.
- caveat: the first admin account must be created through environment variables or the first-run UI; no default account is shipped (inferred).
- caveat: the draft installs miniflux through apt, so the packaged version may lag the chart's 2.3.5 tag and must be checked on arm64 Ubuntu (inferred).

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: miniflux
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/miniflux/miniflux:2.3.5`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/miniflux/v2/blob/2.3.5/packaging/docker/alpine/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/miniflux/v2)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: binary: `apt:miniflux`

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Go RSS reader. Release binaries exist for linux amd64 and arm64, so copy the binary into /app on containerforge-ubuntu. It needs an external PostgreSQL rather than an in-image service, which keeps the port simple.

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

- **Dependency containers**: postgresql ✅
