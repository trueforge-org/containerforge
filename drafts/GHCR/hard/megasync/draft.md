# megasync

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: hard
- **Chart**: megasync
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/megasync
- **Source repository**: https://github.com/meganz/MEGAsync
- **Documentation**: https://help.mega.io/installs-apps/desktop
- **Website**: https://mega.io/desktop

## Potentially relevant resources

- **Container image**: https://ghcr.io/ich777/megasync
- **Source code repository**: https://github.com/ich777/docker-megasync

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Qt desktop client installed from a deb package.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: megasync (MEGA apt repo .deb), Qt libs as deps (inferred)
- python/pip: none
- node/npm: none
- other: none

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8080/http (noVNC web UI, inferred), 5900/tcp (VNC, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/megasync
- non-root: no - chart sets runAsNonRoot false and runAsUser 0
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - not set in values
- other-security: hostpath key mounted at /mnt/host; no type set in values, so it defaults to pvc, though the name suggests hostPath (verify)
- extra-persistence: /data (data, pvc chart default); /mnt/host (hostpath, type unclear, possibly hostPath)
- confidence: medium

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: the MEGA account login is entered in the GUI, so the container is not usable without a MEGA account (inferred)
- caveat: the hostpath mount at /mnt/host has no type in the chart values and may behave as a PVC rather than a host path, so it must be verified (verify)
- caveat: the client is closed-source Qt and needs a desktop over VNC, with no arm64 copy-from image available (inferred)

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: megasync
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/ich777/megasync:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/ich777/docker-megasync/blob/master/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/meganz/MEGAsync)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://mega.nz/linux/repo/xUbuntu_24.04/amd64/megasync_6.7.1-1.1_amd64.deb) · [arm64](https://mega.nz/linux/repo/xUbuntu_24.04/arm64/megasync_6.7.1-1.1_arm64.deb)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: MEGAsync is a closed-source Qt desktop client from the MEGA apt repo shown through noVNC, so it is a desktop/VNC image needing Qt libraries, a tray/GUI stack and rootless rework on a read-only rootfs. Vendor publishes debs for both architectures.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [ghcr.io/ich777/megasync:latest](https://ghcr.io/ich777/megasync)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
