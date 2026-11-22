# z80pack

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: z80pack
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/z80pack
- **Source repository**: https://github.com/udo-munk/z80pack
- **Documentation**: https://www.icl1900.co.uk/unix4fun/z80pack

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/dlandon/z80pack
- **Container image**: https://registry.hub.docker.com/r/dlandon/z80pack

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Emulator built with make from source tarballs, so a build stage on ubuntu fits.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: build-essential (inferred)
- python/pip: none
- node/npm: none
- other: source tarball built with make

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8080/http (web terminal, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/z80pack
- non-root: possible - chart sets runAsUser and runAsGroup 0; emulator and web terminal run fine on a high port
- read-only-rootfs: possible - chart sets false; draft keeps state in /config
- privileged: no - default false, not overridden
- other-security: none
- extra-persistence: none (only /config)
- confidence: medium

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: No prebuilt binary is published, so both amd64 and arm64 need a source build, and copy-from is not available for arm64, which makes the build slower and less certain (inferred).
- caveat: CP/M disk images are not bundled, so the user has to supply them under /config before the emulator does anything useful (inferred).
- caveat: The upstream image is built on the phusion/runit init, which the draft drops, so the web terminal or console startup needs a replacement wrapper (inferred).

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: z80pack
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/dlandon/z80pack:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/dlandon/z80pack/blob/ae67a0f2e18868f5ccc99eff31973183c4965aa6/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/udo-munk/z80pack)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Open-source Z80/CP/M emulator built with make from source tarballs; on containerforge-ubuntu this is a build stage plus a small runtime with a web terminal or console wrapper. The phusion/runit root init goes away, so it is a modest source build with state in /config.

### amd64 / arm64

How we get the application for that architecture.

- `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.

- **amd64**: compile
- **arm64**: compile

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [dlandon/z80pack:latest](https://hub.docker.com/r/dlandon/z80pack)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
