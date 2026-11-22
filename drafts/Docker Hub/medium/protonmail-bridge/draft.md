# protonmail-bridge

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: protonmail-bridge
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/protonmail-bridge
- **Source repository**: https://github.com/ProtonMail/proton-bridge
- **Documentation**: https://proton.me/support/mail/bridge
- **Website**: https://proton.me/mail/bridge

## Potentially relevant resources

- **Source code repository**: https://github.com/shenxn/protonmail-bridge-docker
- **Container image**: https://hub.docker.com/r/shenxn/protonmail-bridge

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Vendor .deb on amd64 and a Go build on arm64, both on ubuntu.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: pass (inferred); gnupg (inferred); libsecret-1-0 (inferred)
- python/pip: none
- node/npm: none
- other: vendor .deb (amd64); Go toolchain for make build-nogui (arm64)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 1143/tcp (IMAP, inferred), 1025/tcp (SMTP, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/protonmail-bridge
- non-root: no - runAsUser 0, runAsNonRoot false in values
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - common default false, not overridden
- other-security: none
- extra-persistence: /root (chart's config, pvc default); the draft's home directory must point at /config
- confidence: medium

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: A paid Proton account is required, and the first login is an interactive step through the bridge CLI, not a config file.
- caveat: The keychain needs pass and gpg in a headless container, and state must live under /config (inferred).
- caveat: arm64 is built from source with Go (make build-nogui), so it is a separate and slower build path.

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: protonmail-bridge
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/shenxn/protonmail-bridge:3.19.0-1`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/shenxn/protonmail-bridge-docker/blob/ae5d201/build/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/ProtonMail/proton-bridge)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/ProtonMail/proton-bridge/releases/download/v3.27.2/protonmail-bridge_3.27.2-1_amd64.deb)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: amd64 installs the vendor deb (gui libs pulled in unless unpacked manually), arm64 builds make build-nogui with Go. Needs pass and gpg keychain plus config under a home directory, which must point at /config for the rootless read-only layout.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.
- `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.

- **amd64**: yes
- **arm64**: compile

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [shenxn/protonmail-bridge:3.19.0-1](https://hub.docker.com/r/shenxn/protonmail-bridge)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
