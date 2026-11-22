# xware

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: xware
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/xware
- **Website**: https://www.xunlei.com/
- **Documentation**: https://help.xunlei.com/

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/caiguai/docker-xware

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Closed-source x86 binary from a vendor tarball, so ubuntu hosts it.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: lib32stdc++6, libc6-i386 (inferred)
- python/pip: none
- node/npm: none
- other: xware.tar.bz vendor tarball from the upstream repo (x86 only)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 2345/http (web UI, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/xware
- non-root: no - chart sets runAsUser 0, runAsGroup 0
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - default false, no override
- other-security: none
- extra-persistence: none (persistence {}); service disabled in values
- confidence: medium

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: the Xunlei binary is closed-source, x86 only, and needs 32-bit i386 libraries (inferred)
- caveat: the binary is shipped as a tarball committed to the upstream repo, so its origin and license must be checked before reuse (inferred)
- caveat: the xware service depends on Xunlei cloud services, which may stop working or change without notice (inferred)
- caveat: the upstream image is tagged latest and built on an old Debian release (inferred)

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: xware
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/caiguai/docker-xware:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/caiguai/docker-xware/blob/master/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://www.xunlei.com/)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/caiguai/docker-xware/raw/master/xware.tar.bz)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Closed-source Xunlei xware binary from a vendor tarball committed to the repo, built on Debian wheezy with i386 libraries and started by a script. Needs a 32-bit x86 runtime and rework for rootless and read-only operation, and the binary is x86 only.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.
- `no`: neither works for that architecture, for example closed-source software where the vendor only ships an amd64 executable.

- **amd64**: yes
- **arm64**: no

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [caiguai/docker-xware:latest](https://hub.docker.com/r/caiguai/docker-xware)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
