# clamav

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: clamav
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/clamav
- **Source repository**: https://github.com/Cisco-Talos/clamav
- **Documentation**: https://docs.clamav.net/

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/clamav/clamav

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Debian package install running clamd and freshclam daemons.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: clamav, clamav-daemon, clamav-freshclam
- python/pip: none
- node/npm: none
- other: none (vendor .deb also published, amd64 and arm64)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 3310/tcp (clamd)

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: clamav
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/clamav/clamav:1.5.5`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/Cisco-Talos/clamav-docker/blob/0d44a2479470a57af03f1e212e764f1bee57fc8a/clamav/1.5/debian/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/Cisco-Talos/clamav)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/Cisco-Talos/clamav/releases/download/clamav-1.5.5/clamav-1.5.5.linux.x86_64.deb) · [arm64](https://github.com/Cisco-Talos/clamav/releases/download/clamav-1.5.5/clamav-1.5.5.linux.aarch64.deb)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: ClamAV built from source with cmake on Debian 13, but the runtime needs clamd and freshclam running together with a writable signature database and socket. Multi-process daemons and signature updates make this hard; the Debian package install itself is simple.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [clamav/clamav:1.5.5](https://hub.docker.com/r/clamav/clamav)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
