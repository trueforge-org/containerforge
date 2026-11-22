# tagspaces

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: easy
- **Chart**: tagspaces
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/tagspaces
- **Source repository**: https://github.com/tagspaces/tagspaces
- **Documentation**: https://docs.tagspaces.org/

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/fardjad/tagspaces-lite-web

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [nginx](https://github.com/trueforge-org/containerforge/tree/main/apps/nginx) (`ghcr.io/trueforge-org/nginx`)
- **Alternative runtime image**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`)
- **Reason**: Static web bundle served by nginx.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: none
- other: amd64 release .deb (dpkg -x); arm64 link points to a mac zip, needs check

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 80/http (nginx static web bundle)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/tagspaces
- non-root: yes - no runAs override, common default 568
- read-only-rootfs: possible - chart sets readOnlyRootFilesystem false; nginx cache goes to an emptyDir
- privileged: no - not set, common default false
- other-security: none
- extra-persistence: /var/cache/nginx (emptyDir, chart's own)
- confidence: medium

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: the amd64 build uses an upstream .deb unpacked with dpkg, and the arm64 link points to a Mac zip, so arm64 is not supported as currently specified.
- caveat: the web bundle is a lite web client that stores its data in the browser or mounted workspace, so the workspace path must be mounted and writable (inferred).
- caveat: the upstream image is maintained by a third party (fardjad), so track its updates separately from the official TagSpaces releases (inferred).

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: tagspaces
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/fardjad/tagspaces-lite-web:6.0.2`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/fardjad/tagspaces-lite-docker/blob/495b1805d716d826fdd70ddc558df4a700b364be/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/tagspaces/tagspaces)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/tagspaces/tagspaces/releases/download/v6.0.2/tagspaces-linux-amd64-6.0.2.deb) · [arm64](https://github.com/tagspaces/tagspaces/releases/download/v6.0.2/tagspaces-mac-arm64-6.0.2.zip)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Static tagspaces-lite web bundle served by nginx, so reuse the ContainerForge nginx app and place the bundle in /app. No runtime processes beyond nginx and no native code. Writes go to /tmp, and the wrapper only copies files.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [fardjad/tagspaces-lite-web:6.0.2](https://hub.docker.com/r/fardjad/tagspaces-lite-web)
- **copy-from arm64**: [fardjad/tagspaces-lite-web:6.0.2](https://hub.docker.com/r/fardjad/tagspaces-lite-web)

### Dependency containers

- **Dependency containers**: none
