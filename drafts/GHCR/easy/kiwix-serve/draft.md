# kiwix-serve

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: easy
- **Chart**: kiwix-serve
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/kiwix-serve
- **Source repository**: https://github.com/kiwix/kiwix-tools
- **Documentation**: https://kiwix-tools.readthedocs.org/en/latest/?badge=latest
- **Documentation**: https://wiki.kiwix.org/wiki/Kiwix-serve
- **Website**: https://kiwix.org/en/

## Potentially relevant resources

- **Container image**: https://ghcr.io/kiwix/kiwix-serve
- **Source code repository**: https://github.com/kiwix/kiwix-tools/blob/master/docker/server
- **Website**: https://www.kiwix.org

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: C++ binary from kiwix-tools, available on ubuntu via apt.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: kiwix-tools
- python/pip: none
- node/npm: none
- other: none

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8080/http (library web UI)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/kiwix-serve
- non-root: possible - chart sets runAsUser 0 and runAsNonRoot false; the draft's binary only serves ZIM files and needs no root
- read-only-rootfs: possible - chart sets readOnlyRootFilesystem false; draft writes only to /config and /tmp
- privileged: no - no privileged key in values; common default false
- other-security: none
- extra-persistence: none for the draft (uses /config); chart mounts /data (pvc default)
- confidence: medium

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: kiwix-serve
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/kiwix/kiwix-serve:3.8.2`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/kiwix/kiwix-tools/blob/3.8.2/docker/server/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/kiwix/kiwix-tools)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: binary: `apt:kiwix-tools`

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: kiwix-serve is a C++ binary shipped in kiwix-tools release tarballs; the upstream image is a thin wrapper around it. On ubuntu, copy the binary into /app and serve ZIM files from /config. No services and no compile. Easy.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/kiwix/kiwix-serve:3.8.2](https://ghcr.io/kiwix/kiwix-serve)
- **copy-from arm64**: [ghcr.io/kiwix/kiwix-serve:3.8.2](https://ghcr.io/kiwix/kiwix-serve)

### Dependency containers

- **Dependency containers**: none
