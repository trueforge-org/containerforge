# anki-sync-server

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: easy
- **Chart**: anki-sync-server
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/anki-sync-server
- **Source repository**: https://github.com/ankicommunity/anki-sync-server-rs
- **Documentation**: https://docs.ankiweb.net/sync-server.html

## Potentially relevant resources

- **Source code repository**: https://github.com/ankicommunity/anki-devops-services
- **Container image**: https://hub.docker.com/r/ankicommunity/anki-sync-server-rs

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Prebuilt Rust server binary unpacked into /app on the ubuntu base.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: none
- other: prebuilt ankisyncd tarball (per arch)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8080/http (sync API, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/anki-sync-server
- non-root: no - chart sets runAsUser 0, runAsNonRoot false
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - not set, common default false
- other-security: none
- extra-persistence: /app/data (chart config volume, pvc default)
- confidence: high

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: The sync server is driven by Anki clients that must be pointed at a custom sync URL. Users are created by hand, so initial account setup is manual (inferred).
- caveat: Data location conflicts. The Reason says data is kept in /config, but the chart's data path is /app/data, so the write path must be verified before mounting (inferred).

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: anki-sync-server
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/ankicommunity/anki-sync-server-rs:1.1.4`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/ankicommunity/anki-sync-server-rs/blob/1.1.4/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/ankicommunity/anki-sync-server-rs)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/ankicommunity/anki-sync-server-rs/releases/download/1.1.4/ankisyncd_1.1.4_linux_x64.tar.gz) · [arm64](https://github.com/ankicommunity/anki-sync-server-rs/releases/download/1.1.4/ankisyncd_1.1.4_linux_arm64.tar.gz)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Rust sync server. Upstream publishes ankisyncd linux x64 and arm64 tarballs, so the cargo build stage is avoidable. Unpack the binary into /app on containerforge-ubuntu, keep data in /config, and run one process.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ankicommunity/anki-sync-server-rs:1.1.4](https://hub.docker.com/r/ankicommunity/anki-sync-server-rs)
- **copy-from arm64**: [ankicommunity/anki-sync-server-rs:1.1.4](https://hub.docker.com/r/ankicommunity/anki-sync-server-rs)

### Dependency containers

- **Dependency containers**: none
