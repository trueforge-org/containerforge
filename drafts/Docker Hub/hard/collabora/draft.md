# collabora

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: collabora
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/collabora
- **Source repository**: https://github.com/CollaboraOnline/online
- **Website**: https://collaboraonline.com

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/collabora/code

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Office server binaries with chroot jails and no language runtime.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: coolwsd, code-brand (inferred), libreoffice-core (inferred), libcap2-bin (inferred)
- python/pip: none
- node/npm: none
- other: Collabora apt repo packages (vendor pipeline), chroot jail setup

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 9980/http (inferred, CODE server; TLS usually terminated by a proxy)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/collabora
- non-root: possible - runAsUser 1001 override, non-root but not 568
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - not set, but allowPrivilegeEscalation true
- other-security: capabilities add CHOWN, FOWNER, SYS_CHROOT, MKNOD; allowPrivilegeEscalation true; chroot jails per draft
- extra-persistence: none shown in values
- confidence: medium

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: the image is large because it bundles the LibreOffice kit, so expect high disk and RAM use (inferred).
- caveat: chroot jails need a writable path and the host must allow them, so a read-only rootfs or restricted runtime will fail (inferred).
- caveat: TLS is usually terminated by a reverse proxy in front of port 9980, and the proxy must be set up before the server works from browsers (inferred).

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: collabora
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/collabora/code:26.04.6.1.1`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

`-` means no public Dockerfile could be found.

- **Dockerfile**: -

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/CollaboraOnline/online)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://www.collaboraonline.com/code/)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Collabora Online CODE server (coolwsd plus LibreOffice kit and chroot jails) with no public Dockerfile; the image comes from Collabora's own pipeline. Rebuilding means several processes, jail capabilities and a large LibreOffice runtime, so the effort is substantial.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [collabora/code:26.04.6.1.1](https://hub.docker.com/r/collabora/code)
- **copy-from arm64**: [collabora/code:26.04.6.1.1](https://hub.docker.com/r/collabora/code)

### Dependency containers

- **Dependency containers**: none
