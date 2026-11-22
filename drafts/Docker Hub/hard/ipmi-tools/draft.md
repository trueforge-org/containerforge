# ipmi-tools

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: ipmi-tools
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/ipmi-tools
- **Source repository**: https://github.com/EdwardChamberlain/IPMI-Fan-Controller

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/edchamberlain/ipmi-tools

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [python](https://github.com/trueforge-org/containerforge/tree/main/apps/python) (`ghcr.io/trueforge-org/python`)
- **Alternative runtime image**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`)
- **Reason**: Python Flask app that shells out to ipmitool from apt.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: ipmitool
- python/pip: flask (inferred)
- node/npm: none
- other: repo archive download (zip at pinned commit)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 5000/http (Flask web UI, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/ipmi-tools
- non-root: possible - no override, common runAsUser 568; /dev/ipmi* access may need root or a device group
- read-only-rootfs: yes - no override, common default true; writes go to /data
- privileged: unknown - values show no privileged flag or /dev/ipmi mount; draft says the host IPMI device is needed
- other-security: none in values; host IPMI device passthrough is not shown
- extra-persistence: /data (pvc, chart default)
- confidence: medium

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: The app needs the host IPMI device (/dev/ipmi*) and the ipmi kernel modules loaded on the host, which the chart does not provide (inferred).
- caveat: Fan control writes to the BMC, so a misconfigured fan curve can cause overheating or noise; test with monitoring first (inferred).
- caveat: Upstream is a zip of a repo at a pinned commit, with no release or tagged image, so updates must be tracked by hand.

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: ipmi-tools
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/edchamberlain/ipmi-tools:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/EdwardChamberlain/IPMI-Fan-Controller/blob/d1ea5f15163a5ca6a5e20d6ba5c9b2fea128b246/dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/EdwardChamberlain/IPMI-Fan-Controller)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/EdwardChamberlain/IPMI-Fan-Controller/archive/d1ea5f15163a5ca6a5e20d6ba5c9b2fea128b246.zip)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Python Flask fan controller that shells out to ipmitool from apt. It needs access to the host IPMI device (/dev/ipmi*), which is hardware access that a rootless read-only container cannot get without device passthrough. Python and apt work on containerforge-ubuntu.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [edchamberlain/ipmi-tools:latest](https://hub.docker.com/r/edchamberlain/ipmi-tools)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
