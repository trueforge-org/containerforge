# backuppc

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: hard
- **Chart**: backuppc
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/backuppc
- **Source repository**: https://github.com/backuppc/backuppc
- **Documentation**: https://backuppc.github.io/backuppc/

## Potentially relevant resources

- **Website**: https://backuppc.github.io/backuppc/index.html
- **Container image**: https://ghcr.io/adferrand/backuppc
- **Source code repository**: https://github.com/adferrand/docker-backuppc

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Perl app served by Apache; Perl has no base, so apt packages on ubuntu.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: backuppc (inferred), apache2, openssh-server, rsync, perl (inferred)
- python/pip: none
- node/npm: none
- other: BackupPC 4.4.0 release tarball

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 80/http (BackupPC web UI via Apache), 443/https (inferred), 22/tcp (sshd for backup clients)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/backuppc
- non-root: no - chart forces runAsUser 0 and runAsNonRoot false (root-owned backup storage)
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - not set, default false
- other-security: none in values (sshd and rsync per Reason are not shown)
- extra-persistence: /etc/backuppc, /home/backuppc, /data/backuppc (type not set, likely pvc)
- confidence: medium

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: backup storage is root-owned, so the mounted data paths must allow root writes and the container cannot run as a non-root user without rework (inferred).
- caveat: the BackupPC admin password and the backup client SSH keys are set up by hand in the web UI or config files after first start (inferred).
- caveat: the upstream install step was not traced, so the package list and the 4.4.0 tarball layout may change once it is checked.

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: backuppc
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/adferrand/backuppc:4`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/adferrand/docker-backuppc/blob/cf90ead82e93b0af92f4d6d1f0ae28b6ff1c1a69/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/backuppc/backuppc)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/BackupPC/backuppc/releases/download/4.4.0/BackupPC-4.4.0.tar.gz)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Perl BackupPC served by Apache, with sshd and rsync for backup clients and root-owned backup storage. That is several services and root-owned paths, which need rework to run rootless on a read-only rootfs. The upstream install step was not traced, so this rating is provisional.

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
