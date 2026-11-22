# minecraft-java

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: medium
- **Chart**: minecraft-java
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/minecraft-java
- **Website**: https://www.minecraft.net/en-us/download/server

## Potentially relevant resources

- **Container image**: https://ghcr.io/itzg/minecraft-server
- **Source code repository**: https://github.com/itzg/docker-minecraft-server

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [java21](https://github.com/trueforge-org/containerforge/tree/main/apps/java21) (`ghcr.io/trueforge-org/java21`)
- **Alternative runtime image**: [java25](https://github.com/trueforge-org/containerforge/tree/main/apps/java25) (`ghcr.io/trueforge-org/java25`)
- **Reason**: Java server jar; draft suggests java21 or java25 and the image tags span several versions.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: none
- other: server jar fetched at runtime by itzg mc-image-helper; RCON and helper tools (release downloads); JVM from java21 or java25 sibling

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 25565/tcp (game), 25575/tcp (RCON)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/minecraft-java
- non-root: possible - runAsUser 568 default, no override; draft mentions itzg helper tools, which may expect a root start
- read-only-rootfs: yes - default true, not overridden; world data is on the /data mount
- privileged: no - default false, not overridden
- other-security: none
- extra-persistence: /data (pvc, world and config). Draft says /config, the chart uses /data.
- confidence: low

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: the operator must accept the Mojang EULA before the server starts (licensing).
- caveat: the server jar is fetched at runtime by the helper, so first start needs internet and a large download, and the Java heap needs enough RAM (runtime download, resource).
- caveat: the upstream tag list is long and ambiguous, so the pinned tag needs confirming (upstream status, inferred).

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: minecraft-java
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/itzg/minecraft-server:2024.6.1-java17-jdk, 2026.11.0-java11, 2026.11.0-java16 (+7)`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/itzg/docker-minecraft-server/blob/1ccd6a0954f6/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://www.minecraft.net/en-us/download/server)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://www.minecraft.net/en-us/download/server)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Java server jar fetched at runtime by itzg mc-image-helper, with RCON and helper tools. Reuse a java21 or java25 sibling, keep world and config in /config, and move helper state to /tmp. The version-selection logic and many helper tools make it medium.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/itzg/minecraft-server:2024.6.1-java17-jdk](https://ghcr.io/itzg/minecraft-server)
- **copy-from arm64**: [ghcr.io/itzg/minecraft-server:2024.6.1-java17-jdk](https://ghcr.io/itzg/minecraft-server)

### Dependency containers

- **Dependency containers**: none
