# glauth

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: easy
- **Chart**: glauth
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/glauth
- **Source repository**: https://github.com/glauth/glauth
- **Documentation**: https://glauth.github.io/

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/glauth/glauth

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Static Go LDAP server binary.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: none
- other: glauth Go binary (per arch)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 389/tcp (LDAP), 636/tcp (LDAPS, inferred), 5555/http (API, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/glauth
- non-root: no - chart sets runAsUser 0, runAsGroup 0
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - not set, common default false
- other-security: none
- extra-persistence: /app/config (config volume, pvc default)
- confidence: high

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: The config file under /app/config must be written by hand, since the defaults are sample data and not production settings (inferred).
- caveat: LDAPS on 636 needs a certificate that the user provides, and plain LDAP on 389 transmits credentials in clear text (inferred).
- caveat: The chart's config path /app/config does not match the draft's /config, so the mount path must be settled before porting (inferred).

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: glauth
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/glauth/glauth:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/glauth/glauth/blob/251ec3ef667e7e51f4b38c3f52c048f7f20dfc32/v2/docker/Dockerfile-standalone)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/glauth/glauth)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/glauth/glauth/releases/download/GLAuth-v2.5.4/glauth-linux-amd64) · [arm64](https://github.com/glauth/glauth/releases/download/GLAuth-v2.5.4/glauth-linux-arm64)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Static Go LDAP server shipped as one binary per arch, so copy it into /app on containerforge-ubuntu. Config lives in /config, and ports above 1024 let it run rootless. No services and no build step.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [glauth/glauth:latest](https://hub.docker.com/r/glauth/glauth)
- **copy-from arm64**: [glauth/glauth:latest](https://hub.docker.com/r/glauth/glauth)

### Dependency containers

- **Dependency containers**: none
