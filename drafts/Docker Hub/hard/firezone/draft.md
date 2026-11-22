# firezone

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: firezone
- **Rows**: 1
- **Hard dependency containers**: yes (postgresql)
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/firezone
- **Source repository**: https://github.com/firezone/firezone
- **Documentation**: https://www.firezone.dev/kb
- **Website**: https://www.firezone.dev

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/firezone/firezone

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Guess: Elixir release with no Elixir base, so ubuntu is the fallback.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none at runtime (postgres from sibling); build stage only: erlang-base, elixir (inferred)
- python/pip: none
- node/npm: node for Phoenix asset build (inferred)
- other: Erlang/OTP and Elixir toolchain via mix (build stage, inferred); mix release of firezone 0.7.36

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 80/http (portal, inferred), 443/https (portal, inferred), 51820/udp (WireGuard)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/firezone
- non-root: no - runAsUser 0, runAsGroup 0, PUID 0
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - not set, common default false
- other-security: capabilities add NET_ADMIN, SYS_MODULE
- extra-persistence: /var/firezone (chart persistence, type not shown)
- confidence: high

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: firezone
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/firezone/firezone:0.7.36`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/firezone/firezone/blob/dc71329fa007942ed32c69bd820f66b94cf5a5cc/Dockerfile.prod)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/firezone/firezone)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Elixir mix release built with Erlang and Elixir in a builder stage, copied into alpine. Needs a large Erlang/Elixir toolchain, a postgres database, and the Phoenix asset build. Root in the upstream image, so porting means reworking it for rootless.

### amd64 / arm64

How we get the application for that architecture.

- `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.

- **amd64**: compile
- **arm64**: compile

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: no
- **copy-from arm64**: no

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

- **Dependency containers**: postgresql ✅
