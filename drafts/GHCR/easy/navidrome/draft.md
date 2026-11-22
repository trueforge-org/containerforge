# navidrome

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: easy
- **Chart**: navidrome
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/navidrome
- **Source repository**: https://github.com/navidrome/navidrome
- **Documentation**: https://www.navidrome.org/docs

## Potentially relevant resources

- **Container image**: https://ghcr.io/navidrome/navidrome
- **Source code repository**: https://github.com/deluan/navidrome

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Go static binary with the web UI bundled.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: none
- other: release binary or .deb (navidrome_0.64.2_linux_<arch>.deb)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 4533/http (web UI and API)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/navidrome
- non-root: yes - no securityContext override, common runAsUser 568; single static binary
- read-only-rootfs: yes - common default readOnlyRootFilesystem true; data and cache go to a volume and /tmp
- privileged: no - no privileged key in values; common default false
- other-security: none
- extra-persistence: none for the draft; chart mounts /data and /music (pvc default)
- confidence: medium

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: the music library must be mounted into the container (chart uses /music); without a mounted library Navidrome has nothing to scan.
- caveat: the draft's release assets are .deb packages, so the binary has to be extracted from the package at build time, not copied as a plain executable (inferred).
- caveat: transcoding writes cache data, so /tmp or the cache volume may need significant space for large libraries (inferred).

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: navidrome
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/navidrome/navidrome:0.64.2`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/navidrome/navidrome/blob/101145742f47/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/navidrome/navidrome)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/navidrome/navidrome/releases/download/v0.64.2/navidrome_0.64.2_linux_amd64.deb) · [arm64](https://github.com/navidrome/navidrome/releases/download/v0.64.2/navidrome_0.64.2_linux_arm64.deb)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Go music server with a bundled web UI, released as single static binaries. Copy the navidrome binary into /app on containerforge-ubuntu, and point data and cache at /config and /tmp. Single process, no extra services.

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
