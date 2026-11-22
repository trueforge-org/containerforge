# mindustry

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: medium
- **Chart**: mindustry
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/mindustry
- **Source repository**: https://github.com/Anuken/Mindustry
- **Documentation**: https://mindustrygame.github.io/wiki
- **Website**: https://mindustrygame.github.io

## Potentially relevant resources

- **Website**: https://anuke.itch.io/mindustry
- **Container image**: https://ghcr.io/ich777/mindustry-server

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [java17](https://github.com/trueforge-org/containerforge/tree/main/apps/java17) (`ghcr.io/trueforge-org/java17`)
- **Alternative runtime image**: [java21](https://github.com/trueforge-org/containerforge/tree/main/apps/java21) (`ghcr.io/trueforge-org/java21`)
- **Reason**: Headless server runs from a Java jar; draft allows java17 or java21 and no version is pinned, so java17 is chosen.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: none
- other: server-release.jar release download; JVM from java17 sibling

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 6567/udp (game), 6567/tcp (game, inferred), 8080/http (gotty web console from ich777 wrapper, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/mindustry
- non-root: no - runAsUser 0, runAsGroup 0
- read-only-rootfs: no - readOnlyRootFilesystem false
- privileged: no - default false, not overridden
- other-security: none
- extra-persistence: /mindustry (pvc). Draft says saves go to /config, the chart mounts /mindustry.
- confidence: medium

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: the ich777 wrapper adds a gotty web console on 8080; that gives shell-style access, so it must be protected or left unexposed (security, inferred).
- caveat: the game uses UDP 6567 and clients must reach it directly, so NAT or firewall rules need UDP forwarding (network).
- caveat: no arm64 image is published for the wrapper, so arm64 is untested (architecture).

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: mindustry
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/ich777/mindustry-server:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/ich777/docker-mindustry/blob/master/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/Anuken/Mindustry)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/Anuken/Mindustry/releases/download/v160.8/server-release.jar)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Mindustry headless server runs as a Java server-release jar; reuse the java17 or java21 sibling and keep saves under /config. The ich777 wrapper adds gotty and a start script, so the work is the start script and rootless paths.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [ghcr.io/ich777/mindustry-server:latest](https://ghcr.io/ich777/mindustry-server)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
