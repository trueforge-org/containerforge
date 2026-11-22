# minetest

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR (linuxserver)
- **Difficulty**: easy
- **Chart**: minetest
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/minetest
- **Source repository**: https://github.com/minetest/minetest
- **Documentation**: https://docs.luanti.org/
- **Website**: https://www.luanti.org/

## Potentially relevant resources

- **Container image**: https://ghcr.io/linuxserver/minetest

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: C++ game server installed from apt on ubuntu, with no compile step.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: minetest-server (or luanti-server) | none
- python/pip: none | none
- node/npm: none | none
- other: none

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 30000/udp (game client)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/minetest
- non-root: possible - chart sets runAsUser 0 for linuxserver s6; draft runs apt luanti-server rootless
- read-only-rootfs: possible - chart sets readOnlyRootFilesystem false; draft keeps state in /config
- privileged: no - not set in values
- other-security: none; UDP 30000 only
- extra-persistence: /config/.minetest (pvc, subpath of /config; draft says /config)
- confidence: medium

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: game traffic is UDP 30000 only, so the service must be exposed as UDP and HTTP checks will not reflect game health (inferred)
- caveat: the apt package name differs by Ubuntu release (minetest-server vs luanti-server), so the install line may need changing (inferred)

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: minetest
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/linuxserver/minetest:5.10.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/linuxserver/docker-minetest/blob/6a2d4d1e90c3/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/minetest/minetest)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: binary: `apt:minetest-server`

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Luanti (formerly Minetest) C++ game server. ContainerForge already has apps/luanti, so reuse that sibling; otherwise apt luanti-server installs on both arches with no compile. Worlds and config live in /config and it runs rootless.

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
