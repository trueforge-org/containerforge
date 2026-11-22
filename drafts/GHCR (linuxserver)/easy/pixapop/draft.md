# pixapop

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR (linuxserver)
- **Difficulty**: easy
- **Chart**: pixapop
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/pixapop
- **Source repository**: https://github.com/bierdok

## Potentially relevant resources

- **Container image**: https://ghcr.io/linuxserver/pixapop
- **Source code repository**: https://github.com/bierdok/pixapop
- **Source code repository**: https://github.com/linuxserver/docker-pixapop

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [nginx](https://github.com/trueforge-org/containerforge/tree/main/apps/nginx) (`ghcr.io/trueforge-org/nginx`)
- **Alternative runtime image**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`)
- **Reason**: Static JavaScript gallery served by nginx with no server runtime.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none | none
- python/pip: none | none
- node/npm: none | none
- other: static source tarball served by nginx

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 80/http (static gallery via nginx, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/pixapop
- non-root: possible - chart sets runAsUser 0 for linuxserver; draft serves static files via nginx sibling
- read-only-rootfs: possible - chart sets readOnlyRootFilesystem false; nginx cache/runtime paths not shown
- privileged: no - not set in values
- other-security: none
- extra-persistence: none known
- confidence: low

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: the gallery only shows photos placed in the served path, so the image folder must be mounted or copied in; nginx does not handle uploads (inferred)
- caveat: amd64 and arm64 claims are unconfirmed against upstream, so check that the release tarball exists for both arches before relying on it
- caveat: confidence is low; the draft's PHP-write check is still open and the gallery may need writable thumbnail or cache paths (inferred)

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: pixapop
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/linuxserver/pixapop:v1.2-ls15`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/linuxserver/docker-pixapop/blob/932504b80918/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/bierdok)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Static JavaScript photo gallery from a source tarball of the bierdok/pixapop release. Copy the files into /app and serve them with the ContainerForge nginx sibling, with no runtime process or compile. Confirm no server-side PHP writes are needed before shipping.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.
- A trailing `*` means the claim could not be confirmed against the upstream source, so it is a best judgement and should be rechecked before porting.

- **amd64**: yes*
- **arm64**: yes*

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: no
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
