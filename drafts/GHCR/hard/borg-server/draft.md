# borg-server

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: hard
- **Chart**: borg-server
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/borg-server
- **Source repository**: https://github.com/borgbackup/borg
- **Documentation**: https://borgbackup.readthedocs.io/en/stable/
- **Website**: https://www.borgbackup.org/

## Potentially relevant resources

- **Container image**: https://ghcr.io/anotherstranger/borg-server
- **Source code repository**: https://github.com/AnotherStranger/docker-borg-backup

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [python](https://github.com/trueforge-org/containerforge/tree/main/apps/python) (`ghcr.io/trueforge-org/python`)
- **Reason**: Python pip install of borgbackup is the main runtime; sshd comes from apt.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: openssh-server
- python/pip: borgbackup
- node/npm: none
- other: none

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 22/tcp (sshd for borg clients)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/borg-server
- non-root: no - chart forces runAsUser 0 and runAsNonRoot false (sshd front end)
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - not set, default false
- other-security: capabilities add SYS_CHROOT, KILL; BORG_UID taken from PUID
- extra-persistence: /var/lib/docker-borg, /home/borg/backups, /home/borg/.ssh (type not set, likely pvc)
- confidence: medium

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: clients connect over SSH, so the host port 22 (or another mapped port) must reach the container and the sshd host keys must persist across restarts (inferred).
- caveat: BORG_UID comes from PUID, and it must match the owner of any existing repositories or borg will refuse them (inferred).
- caveat: sshd and borg run together in one image, so logs and restarts are shared between two services (inferred).

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: borg-server
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/anotherstranger/borg-server:2.8.46`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/AnotherStranger/docker-borg-backup/blob/2737b502e67417e06a791c10df33d38726df98dd/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/borgbackup/borg)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: binary: `pip:borgbackup`

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Python app that pip-installs borgbackup and runs an sshd front end, so at least two services run in one image. sshd needs root-owned host keys and config. The python sibling covers the Python side, but the sshd rework is the hard part.

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
