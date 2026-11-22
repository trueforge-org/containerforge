# arksurvivalevolved

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: easy
- **Chart**: arksurvivalevolved
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/arksurvivalevolved
- **Source repository**: https://github.com/arkmanager/ark-server-tools
- **Documentation**: https://github.com/arkmanager/ark-server-tools/wiki

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/drpsychick/arkserver

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [steamcmd](https://github.com/trueforge-org/containerforge/tree/main/apps/steamcmd) (`ghcr.io/trueforge-org/steamcmd`)
- **Reason**: Dedicated game server installed at runtime through SteamCMD.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: none
- other: arkmanager / ark-server-tools (inferred); game files via steamcmd runtime base

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 7777/udp (game), 7778/udp (game raw, inferred), 27015/udp (query, inferred), 27020/tcp (rcon, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/arksurvivalevolved
- non-root: possible - runAsUser 1001 override, but runAsNonRoot false and SteamCMD install plus chown needs root-like caps
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - not set; allowPrivilegeEscalation true
- other-security: capabilities add AUDIT_WRITE, CHOWN, FOWNER, DAC_OVERRIDE, SETGID, SETUID; allowPrivilegeEscalation true; fsGroup 1001
- extra-persistence: /arkserver, /ark, /ark/backup, /ark/staging, /home/steam/.steam/steamapps, /arkserver/ShooterGame/Saved/clusters, /arkserver/ShooterGame/Saved, /arkserver/ShooterGame (pvc default); /arkconfig (configmap); /var/spool/cron/crontabs (emptyDir)
- confidence: high

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: arksurvivalevolved
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/drpsychick/arkserver:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/SickHub/arkserver/blob/394fd7aa4f6321e5665f9dbc7d1ff4600aa6386f/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/arkmanager/ark-server-tools)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: ARK server installed at runtime through arkmanager and SteamCMD, so it fits the ich777-style steamcmd game-server pattern and can reuse apps/steamcmd. Game files are large and go to /config; the ARK server binaries are x86_64 only.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.
- `no`: neither works for that architecture, for example closed-source software where the vendor only ships an amd64 executable.

- **amd64**: yes
- **arm64**: no

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [drpsychick/arkserver:latest](https://hub.docker.com/r/drpsychick/arkserver)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
