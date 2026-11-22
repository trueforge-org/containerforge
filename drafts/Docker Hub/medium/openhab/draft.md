# openhab

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: openhab
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/openhab
- **Source repository**: https://github.com/openhab/openhab-distro
- **Documentation**: https://www.openhab.org/docs/
- **Website**: https://www.openhab.org

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/openhab/openhab

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [java21](https://github.com/trueforge-org/containerforge/tree/main/apps/java21) (`ghcr.io/trueforge-org/java21`)
- **Reason**: The input names java21 for a Java distro run from /app.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: none
- other: openHAB distro tar.gz release

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8080/http (web UI, inferred), 8443/https (web UI TLS, inferred), 8101/tcp (Karaf SSH console, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/openhab
- non-root: no - runAsUser 0, runAsNonRoot false in values
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - common default false, not overridden
- other-security: none; init script mounted from a configmap at /etc/cont-init.d/enable-console-logging.sh
- extra-persistence: /openhab/addons and /openhab/userdata (pvc default, chart's own)
- confidence: medium

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: Java 21 is required, and several Karaf services share one JVM, so memory use is significant (inferred).
- caveat: Bindings and add-ons are installed at runtime from the openHAB repositories, so the first start needs internet and takes a while (inferred).
- caveat: Initial setup happens in the web UI onboarding wizard, not via config files.
- caveat: The Karaf SSH console on 8101 should not be exposed without restriction (inferred).

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: openhab
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/openhab/openhab:5.2.5`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/openhab/openhab-docker/blob/045c5cfacb270a668f3384990b4dcc91235d109f/debian/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/openhab/openhab-distro)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/openhab/openhab-distro/releases/download/5.2.5/openhab-5.2.5.tar.gz)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Java app distributed as a noarch zip of the openHAB distro, so the java21 sibling runs it from /app. State and add-ons go in /config, and the image adds a few helper scripts. Several Karaf services run in one JVM, which needs care but is not a multi-process image.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [openhab/openhab:5.2.5](https://hub.docker.com/r/openhab/openhab)
- **copy-from arm64**: [openhab/openhab:5.2.5](https://hub.docker.com/r/openhab/openhab)

### Dependency containers

- **Dependency containers**: none
