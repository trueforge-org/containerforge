# necesse

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: easy
- **Chart**: necesse
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/necesse
- **Website**: https://necessegame.com
- **Documentation**: https://necessewiki.com

## Potentially relevant resources

- **Container image**: https://ghcr.io/ich777/steamcmd
- **Steam store page**: https://www.steampowered.com

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [steamcmd](https://github.com/trueforge-org/containerforge/tree/main/apps/steamcmd) (`ghcr.io/trueforge-org/steamcmd`)
- **Reason**: Dedicated server pulled from Steam by SteamCMD at start.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: necesse
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/ich777/steamcmd:necesse`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/ich777/docker-steamcmd-server/blob/master/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://necessegame.com)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://store.steampowered.com/app/1169370/)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Reuses apps/steamcmd: SteamCMD (32-bit x86 bootstrap with lib32 libs) pulls the necesse Linux dedicated server from Steam at start into /config, caches in /tmp. The ich777 wrapper runs as root, so work is a USER apps start script, not a build.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [ghcr.io/ich777/steamcmd:necesse](https://ghcr.io/ich777/steamcmd)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
