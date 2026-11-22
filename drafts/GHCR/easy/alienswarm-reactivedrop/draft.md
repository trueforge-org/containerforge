# alienswarm-reactivedrop

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: easy
- **Chart**: alienswarm-reactivedrop
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/alienswarm-reactivedrop
- **Website**: https://developer.valvesoftware.com/wiki/Dedicated_Server_Guide
- **Documentation**: https://developer.valvesoftware.com/wiki/Alien_Swarm:_Reactive_Drop

## Potentially relevant resources

- **Container image**: https://ghcr.io/ich777/steamcmd
- **Steam store page**: https://www.steampowered.com

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [steamcmd](https://github.com/trueforge-org/containerforge/tree/main/apps/steamcmd) (`ghcr.io/trueforge-org/steamcmd`)
- **Reason**: Dedicated server fetched through SteamCMD at start, so the steamcmd base fits.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none (steamcmd base provides lib32 libs)
- python/pip: none
- node/npm: none
- other: SteamCMD via steamcmd base; Reactive Drop server pulled from Steam at start

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 27015/udp (game and query), 27015/tcp (rcon, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/alienswarm-reactivedrop
- non-root: possible - chart runs the ich777 wrapper as runAsUser 0; draft plans a USER apps start script
- read-only-rootfs: possible - chart sets false; draft keeps server files in /config and caches in /tmp
- privileged: no - default false, not overridden
- other-security: none; UDP and TCP 27015 ports
- extra-persistence: /serverdata/serverfiles and /serverdata/steamcmd pvc (chart); likely none beyond /config
- confidence: medium

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: alienswarm-reactivedrop
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/ich777/steamcmd:alienswarmreactivedrop`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/ich777/docker-steamcmd-server/blob/master/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://developer.valvesoftware.com/wiki/Dedicated_Server_Guide)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Reuses apps/steamcmd: SteamCMD is a 32-bit Valve bootstrap that needs lib32 libs and pulls the dedicated server from Steam at start, with server files in /config and caches in /tmp. The ich777 wrapper runs as root, so the main work is dropping that for USER apps and mapping config, not building anything.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.
- `no`: neither works for that architecture, for example closed-source software where the vendor only ships an amd64 executable.

- **amd64**: yes
- **arm64**: no

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [ghcr.io/ich777/steamcmd:alienswarmreactivedrop](https://ghcr.io/ich777/steamcmd)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
