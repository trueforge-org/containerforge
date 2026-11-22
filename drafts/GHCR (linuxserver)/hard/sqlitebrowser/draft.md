# sqlitebrowser

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR (linuxserver)
- **Difficulty**: hard
- **Chart**: sqlitebrowser
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/sqlitebrowser
- **Source repository**: https://github.com/sqlitebrowser/sqlitebrowser
- **Documentation**: https://github.com/sqlitebrowser/sqlitebrowser/wiki
- **Website**: https://sqlitebrowser.org

## Potentially relevant resources

- **Container image**: https://ghcr.io/linuxserver/sqlitebrowser
- **Source code repository**: https://github.com/linuxserver/docker-sqlitebrowser

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Desktop GUI from an AppImage or apt package on ubuntu.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: sqlitebrowser (arm64 per spec; amd64 could use it too) | none
- python/pip: none | none
- node/npm: none | none
- other: amd64 AppImage download (libfuse2 if used, inferred)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 3000/http (desktop web UI, inferred), 3001/https (desktop web UI, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/sqlitebrowser
- non-root: no - chart runAsUser 0; draft GUI over rdesktop-web needs rootless rework
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - not set in values
- other-security: root, so common root caps added
- extra-persistence: none
- confidence: medium

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: amd64 uses an AppImage while arm64 uses the apt package, so the two architectures run different builds and may differ in version (inferred)
- caveat: SQLite database files must be mounted into the container to be opened, and paths outside the mount are invisible (data gotcha) (inferred)

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: sqlitebrowser
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/linuxserver/sqlitebrowser:18.04.1`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/linuxserver/docker-sqlitebrowser/blob/07d24df2caea/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/sqlitebrowser/sqlitebrowser)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/sqlitebrowser/sqlitebrowser/releases/download/v3.13.1/DB.Browser.for.SQLite-v3.13.1-x86.64-v2.AppImage) · arm64: `apt:sqlitebrowser`

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Qt desktop SQLite browser served through an rdesktop-web image on an old Ubuntu base. The apt package sqlitebrowser is available for both arches, but a GUI delivered over VNC or the web is a desktop image that needs rootless rework, so it is hard.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/linuxserver/sqlitebrowser:18.04.1](https://ghcr.io/linuxserver/sqlitebrowser)
- **copy-from arm64**: [ghcr.io/linuxserver/sqlitebrowser:18.04.1](https://ghcr.io/linuxserver/sqlitebrowser)

### Dependency containers

- **Dependency containers**: none
