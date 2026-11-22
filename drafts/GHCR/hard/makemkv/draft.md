# makemkv

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: hard
- **Chart**: makemkv
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/makemkv
- **Website**: https://www.makemkv.com/
- **Documentation**: https://forum.makemkv.com/forum/

## Potentially relevant resources

- **Container image**: https://ghcr.io/jlesage/makemkv
- **Source code repository**: https://github.com/jlesage/docker-makemkv

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Vendor binaries built with make, so ubuntu covers it.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: make, gcc, g++, libssl-dev (inferred), libexpat1-dev (inferred)
- python/pip: none
- node/npm: none
- other: makemkv-bin and makemkv-oss vendor tarballs (makemkv.com)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 5800/http (noVNC web UI), 5900/tcp (VNC)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/makemkv
- non-root: no - chart sets runAsNonRoot false and runAsUser 0
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - not set in values
- other-security: capabilities add NET_BIND_SERVICE and KILL; no device mounts in values (a disc drive would need one, not shown)
- extra-persistence: /storage (pvc chart default); /output (pvc chart default)
- confidence: medium

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: ripping needs the optical drive passed into the container as a device, and the chart values do not show one (inferred)
- caveat: MakeMKV needs a registration key or beta key entered in its UI, and keys expire and need renewing (inferred)
- caveat: arm64 support rests on vendor tarballs from makemkv.com, and the build depends on that site being reachable (inferred)

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: makemkv
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/jlesage/makemkv:v26.09.2`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/jlesage/docker-makemkv/blob/v26.09.2/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://www.makemkv.com/)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://www.makemkv.com/download/makemkv-bin-2.0.0.tar.gz)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Vendor tarballs makemkv-bin and makemkv-oss from makemkv.com cover amd64 and arm64; oss part is built with make on containerforge-ubuntu. Upstream wraps it in a GUI over VNC (jlesage base), which needs a rootless kasmvnc or xvfb stack and /config for settings.

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
