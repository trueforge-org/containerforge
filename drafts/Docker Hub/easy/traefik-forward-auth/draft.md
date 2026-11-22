# traefik-forward-auth

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: easy
- **Chart**: traefik-forward-auth
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/traefik-forward-auth
- **Source repository**: https://github.com/thomseddon/traefik-forward-auth

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/thomseddon/traefik-forward-auth

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Small Go binary from the release download.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: none
- other: Go toolchain for arm64 source build; amd64 release binary

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 4181/http (auth endpoint)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/traefik-forward-auth
- non-root: yes - no security override, common default 568
- read-only-rootfs: yes - default readOnlyRootFilesystem true, no override
- privileged: no - not set, common default false
- other-security: none
- extra-persistence: none
- confidence: high

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: an OAuth or OIDC provider, client ID and secret, and a cookie secret must be configured before the forward-auth endpoint works, so it cannot run alone (inferred).
- caveat: arm64 is a source build that needs the Go toolchain, so build time is longer on arm64 (inferred).

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: traefik-forward-auth
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/thomseddon/traefik-forward-auth:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/thomseddon/traefik-forward-auth/blob/83f06df/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/thomseddon/traefik-forward-auth)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/thomseddon/traefik-forward-auth/releases/download/v2.3.0/traefik-forward-auth_amd64)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Small Go binary, so ContainerForge can build it in a golang stage or use the release binary. The latest release only ships amd64 and arm assets, so arm64 needs a Go build from source. It is a single process with no state beyond config.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.
- `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.

- **amd64**: yes
- **arm64**: compile

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [thomseddon/traefik-forward-auth:latest](https://hub.docker.com/r/thomseddon/traefik-forward-auth)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
