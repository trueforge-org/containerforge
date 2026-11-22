# minecraft-proxy

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: medium
- **Chart**: minecraft-proxy
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/minecraft-proxy
- **Source repository**: https://github.com/PaperMC/Velocity
- **Website**: https://papermc.io/software/velocity

## Potentially relevant resources

- **Container image**: https://ghcr.io/itzg/mc-proxy
- **Source code repository**: https://github.com/itzg/docker-mc-proxy

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [java17](https://github.com/trueforge-org/containerforge/tree/main/apps/java17) (`ghcr.io/trueforge-org/java17`)
- **Alternative runtime image**: [java25](https://github.com/trueforge-org/containerforge/tree/main/apps/java25) (`ghcr.io/trueforge-org/java25`)
- **Reason**: JVM proxy jar; draft suggests java17 or java25.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: none
- other: Velocity or BungeeCord jar fetched at runtime by itzg mc-image-helper; JVM from java17 or java25 sibling

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 25577/tcp (proxy game port)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/minecraft-proxy
- non-root: possible - runAsUser 568 default, no override; itzg helper tools may expect a root start
- read-only-rootfs: yes - default true, not overridden
- privileged: no - default false, not overridden
- other-security: none
- extra-persistence: /server (pvc); /plugins (pvc)
- confidence: low

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: it is only useful with backend Minecraft servers that the operator has already set up and can reach (external service).
- caveat: the proxy jar is fetched at runtime by the helper, so it needs internet on first start (runtime download).
- caveat: the forwarding secret must match between the proxy and each backend server, which is a manual setup step (manual setup, inferred).

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: minecraft-proxy
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/itzg/mc-proxy:2026.11.1-java17, 2026.11.1-java21, 2026.11.1-java25 (+1)`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/itzg/docker-mc-proxy/blob/89a7d3ad7dc6/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/PaperMC/Velocity)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://papermc.io/software/velocity)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: JVM proxy (Velocity or BungeeCord) whose jar is fetched at runtime by itzg mc-image-helper. Reuse a java17 or java25 sibling, put the jar and config in /config, and move helper temp files to /tmp. Several itzg helper tools make it medium, with no service sprawl.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/itzg/mc-proxy:2026.11.1-java17](https://ghcr.io/itzg/mc-proxy)
- **copy-from arm64**: [ghcr.io/itzg/mc-proxy:2026.11.1-java17](https://ghcr.io/itzg/mc-proxy)

### Dependency containers

- **Dependency containers**: none
