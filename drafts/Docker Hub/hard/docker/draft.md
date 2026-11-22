# docker

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: docker
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/docker
- **Source repository**: https://github.com/moby/moby
- **Website**: https://mobyproject.org/

## Potentially relevant resources

- **Container image**: https://hub.docker.com/_/docker

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Static container engine binaries from tarballs with no language runtime.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: iptables, pigz (inferred), xfsprogs (inferred), e2fsprogs (inferred)
- python/pip: none
- node/npm: none
- other: static docker-29.10.0 tarball (amd64 and arm64; bundles dockerd, containerd, runc)

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: docker
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker:29.10.0-dind`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/docker-library/docker/blob/70cd6b52204a3bf037510cb750e099c34b081bd4/29/dind/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/moby/moby)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://download.docker.com/linux/static/stable/x86_64/docker-29.10.0.tgz) · [arm64](https://download.docker.com/linux/static/stable/aarch64/docker-29.10.0.tgz)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Docker-in-Docker (Go, static docker 29.x bundle) runs dockerd, containerd and runc, which need privileged mounts, cgroups and root. It is hard to fit rootless on a read-only rootfs, but it is not impossible in principle (rootless dind exists), so it is hard rather than very-hard.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.
- A trailing `*` means the claim could not be confirmed against the upstream source, so it is a best judgement and should be rechecked before porting.

- **amd64**: yes*
- **arm64**: yes*

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [docker:29.10.0-dind](https://hub.docker.com/_/docker)
- **copy-from arm64**: [docker:29.10.0-dind](https://hub.docker.com/_/docker)

### Dependency containers

- **Dependency containers**: none
