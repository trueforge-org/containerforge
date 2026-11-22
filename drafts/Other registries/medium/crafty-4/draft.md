# crafty-4

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Other registries
- **Difficulty**: medium
- **Chart**: crafty-4
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/crafty-4
- **Source repository**: https://gitlab.com/crafty-controller/crafty-4
- **Documentation**: https://docs.craftycontrol.com/
- **Website**: https://craftycontrol.com/

## Potentially relevant resources

- No additional resources were listed in the TrueCharts chart sources.

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [python](https://github.com/trueforge-org/containerforge/tree/main/apps/python) (`ghcr.io/trueforge-org/python`)
- **Alternative runtime image**: [java21](https://github.com/trueforge-org/containerforge/tree/main/apps/java21) (`ghcr.io/trueforge-org/java21`)
- **Reason**: Python web panel installed from requirements; the Java stack is for spawned Minecraft servers, not the panel itself.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: crafty-4 requirements.txt (inferred)
- node/npm: none
- other: crafty-4 v4.11.1 source; Java runtime via java21 sibling base (not apt)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8443/https (web panel), 8000/http (web panel HTTP, inferred), 25565/tcp (Minecraft game port of spawned servers, inferred)

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: crafty-4
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `registry.gitlab.com/crafty-controller/crafty-4:4.11.1`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://gitlab.com/crafty-controller/crafty-4/-/blob/c5c08effa959d570075f951a364216ebd658ca22/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://gitlab.com/crafty-controller/crafty-4)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://gitlab.com/crafty-controller/crafty-4/-/releases/v4.11.1)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Python web panel installed from requirements.txt into a venv, with a JRE stack for Minecraft servers. Use the python base and the java sibling, keep server data under /config, and check that the server-spawning code does not write under /app.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [registry.gitlab.com/crafty-controller/crafty-4:4.11.1](https://gitlab.com/crafty-controller/crafty-4/container_registry)
- **copy-from arm64**: [registry.gitlab.com/crafty-controller/crafty-4:4.11.1](https://gitlab.com/crafty-controller/crafty-4/container_registry)

### Dependency containers

- **Dependency containers**: none
