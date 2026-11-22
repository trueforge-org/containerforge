# handbrake

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: hard
- **Chart**: handbrake
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/handbrake
- **Source repository**: https://github.com/HandBrake/HandBrake
- **Documentation**: https://handbrake.fr/docs/
- **Website**: https://handbrake.fr/

## Potentially relevant resources

- **Container image**: https://ghcr.io/jlesage/handbrake
- **Source code repository**: https://github.com/jlesage/docker-handbrake

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: GTK app with handbrake-cli available from apt on ubuntu.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: handbrake-cli, handbrake (inferred), libva-drm2 (inferred, VAAPI), vainfo (inferred)
- python/pip: none
- node/npm: none
- other: none

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 5800/http (noVNC web desktop), 5900/tcp (VNC)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/handbrake
- non-root: no - chart forces runAsUser 0 and runAsNonRoot false (GUI base)
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - not set, default false
- other-security: capabilities add NET_BIND_SERVICE, KILL; VAAPI device access from the Reason is not shown
- extra-persistence: /storage, /output (type not set, likely pvc)
- confidence: high

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: the GUI runs through VNC or noVNC, and hardware encoding needs a VAAPI device passed into the container (inferred).
- caveat: Ubuntu's apt handbrake packages can lag the 1.11.2 upstream release, so codec and preset behaviour may differ from the GUI build (inferred).
- caveat: transcodes are CPU heavy and need scratch disk space in the output path (inferred).

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: handbrake
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/jlesage/handbrake:v26.09.1`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/jlesage/docker-handbrake/blob/v26.09.1/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/HandBrake/HandBrake)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/HandBrake/HandBrake/releases/download/1.11.2/HandBrake-1.11.2-x86_64-Win_GUI.zip) · [arm64](https://github.com/HandBrake/HandBrake/releases/download/1.11.2/HandBrake-1.11.2-arm64-Win_GUI.zip)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: HandBrake GTK app compiled from source on a jlesage Alpine GUI base over VNC, but Ubuntu 26.04 ships handbrake and handbrake-cli by apt. Still a desktop/VNC image needing a kasmvnc-style layer, root rework and hardware transcode access (VAAPI), so hard.

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
