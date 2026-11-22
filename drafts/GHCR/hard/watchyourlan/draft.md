# watchyourlan

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: hard
- **Chart**: watchyourlan
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: yes (postgresql)
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/watchyourlan
- **Source repository**: https://github.com/aceberg/WatchYourLAN

## Potentially relevant resources

- **Container image**: https://ghcr.io/aceberg/watchyourlan

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Prebuilt Go web app that runs arp-scan from apt.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: arp-scan
- python/pip: none
- node/npm: none
- other: prebuilt Go binary from release (arm64/amd64 .apk files, extract binary; not an apt package)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8840/http (web UI, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/watchyourlan
- non-root: no - runAsUser 0, runAsGroup 0, runAsNonRoot false
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - not set, common default false
- other-security: hostNetwork true; capabilities add NET_RAW
- extra-persistence: /data (chart path, type not set)
- confidence: high

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: ARP discovery only sees the LAN segment the container is attached to, so devices on other VLANs or subnets are not found (inferred).
- caveat: upstream ships Alpine .apk packages rather than apt packages, so the binary must be extracted for ubuntu (from draft).
- caveat: the PostgreSQL option is optional, and SQLite is the default storage path (inferred).

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: watchyourlan
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/aceberg/watchyourlan:2.1.4`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/aceberg/WatchYourLAN/blob/ca9f644bccba41cdb3db952b828137fa53c2f640/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/aceberg/WatchYourLAN)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/aceberg/WatchYourLAN/releases/download/2.1.4/watchyourlan_2.1.4_linux_amd64.apk) · [arm64](https://github.com/aceberg/WatchYourLAN/releases/download/2.1.4/watchyourlan_2.1.4_linux_arm64.apk)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Go web app that runs arp-scan to discover LAN devices, so it needs raw sockets (NET_RAW) and host networking. The binary itself is easy because upstream ships release tarballs, but the network capabilities make this a hardware and network access case.

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
