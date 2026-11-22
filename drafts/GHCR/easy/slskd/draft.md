# slskd

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: easy
- **Chart**: slskd
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/slskd
- **Source repository**: https://github.com/slskd/slskd
- **Documentation**: https://github.com/slskd/slskd/blob/master/docs/config.md

## Potentially relevant resources

- **Container image**: https://ghcr.io/slskd/slskd
- **Source code repository**: https://github.com/ansible-slskd/slskd

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: .NET server in a release zip, on ubuntu per the .NET rule.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: none
- other: slskd .NET release zip (.NET runtime bundling unconfirmed)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 5030/http (web UI), 5031/https (web UI over TLS, optional), 50300/tcp (peer listener)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/slskd
- non-root: no - chart sets runAsUser 0 and runAsGroup 0
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - not set, default false
- other-security: none
- extra-persistence: /app (pvc, data), /share (pvc), /downloads/incomplete (pvc), /downloads/complete (pvc)
- confidence: high

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: a Soulseek network account with username and password is needed before slskd can connect (account, inferred)
- caveat: the .NET runtime may not be bundled in the release zip, so an apt .NET runtime may be needed (inferred)
- caveat: the peer listener on 50300/tcp should be reachable for good connectivity (inferred)

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: slskd
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/slskd/slskd:0.26.2`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/slskd/slskd/blob/e472ecd/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/slskd/slskd)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/slskd/slskd/releases/download/0.26.2/slskd-0.26.2-linux-musl-x64.zip) · [arm64](https://github.com/slskd/slskd/releases/download/0.26.2/slskd-0.26.2-linux-arm64.zip)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: slskd is a .NET server with its web UI bundled in a release zip for linux x64 and arm64. One process runs with its state in /config and downloads to a mount. It needs the .NET runtime to be bundled in the zip, which should be confirmed.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/slskd/slskd:0.26.2](https://ghcr.io/slskd/slskd)
- **copy-from arm64**: [ghcr.io/slskd/slskd:0.26.2](https://ghcr.io/slskd/slskd)

### Dependency containers

- **Dependency containers**: none
