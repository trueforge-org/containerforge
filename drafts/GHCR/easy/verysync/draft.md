# verysync

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: easy
- **Chart**: verysync
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/verysync
- **Source repository**: https://github.com/Jonnyan404/verysync

## Potentially relevant resources

- **Container image**: https://ghcr.io/jonnyan404/verysync

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Guess: prebuilt linux tarballs with no language stated, so ubuntu.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: none
- other: verysync release tarball per arch (redistribution terms to confirm)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8886/http (web UI, inferred), 22330/tcp (sync, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/verysync
- non-root: no - chart sets runAsUser 0 and runAsGroup 0
- read-only-rootfs: yes - no readOnlyRootFilesystem override, common default true
- privileged: no - not set, default false
- other-security: none
- extra-persistence: /data (pvc), /Sync (pvc)
- confidence: medium

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: the upstream tarballs are committed binaries, and their redistribution terms still need to be confirmed (licensing, per draft)
- caveat: the sync tool may self-update or write into its own install path at runtime, which would break a read-only rootfs (inferred)
- caveat: the first admin account is set in the web UI on first use (manual setup, inferred)

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: verysync
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/jonnyan404/verysync:v2.33.2`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/Jonnyan404/verysync/blob/29eb0b8c40c2e2f9e62b3f00368e152f15066a78/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/Jonnyan404/verysync)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/Jonnyan404/verysync/releases/download/v2.33.2/verysync-docker-v2.33.2-amd64.tar.gz) · [arm64](https://github.com/Jonnyan404/verysync/releases/download/v2.33.2/verysync-docker-v2.33.2-arm64.tar.gz)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Verysync sync tool shipped as linux release tarballs for each arch, which the Dockerfile copies from a files folder onto alpine. On ubuntu, unpack the matching tarball into /app and keep state in /config. Confirm the redistribution terms of the committed binaries before reuse. Easy.

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

- **Dependency containers**: none
