# guacamole

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: guacamole
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: yes (postgresql, guacd)
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/guacamole
- **Source repository**: https://github.com/apache/guacamole-client
- **Documentation**: https://guacamole.apache.org/doc/gug/

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/guacamole/guacamole
- **Container image**: https://hub.docker.com/r/guacamole/guacd

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [java21](https://github.com/trueforge-org/containerforge/tree/main/apps/java21) (`ghcr.io/trueforge-org/java21`)
- **Reason**: The input names jdk21 for a Java war run in a servlet container.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: tomcat10 (inferred)
- python/pip: none
- node/npm: none
- other: guacamole-1.6.0.war (release download); guacd is a separate service, not in this image

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8080/http (web UI via Tomcat)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/guacamole
- non-root: possible - main runAsUser 1001 and guacd runAsUser 1000 overrides; Tomcat runs as non-root user
- read-only-rootfs: possible - chart sets readOnlyRootFilesystem false on main and guacd; Tomcat needs writable tmp and work dirs
- privileged: no - common default, not overridden
- other-security: none
- extra-persistence: /var/lib/guacamole/recordings (pvc, guacd sidecar), /var/lib/guacamole/drive (pvc, guacd sidecar), /tc-init (emptyDir, init seed)
- confidence: medium

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: guacd is a separate service and must run as its own container; the web app cannot proxy RDP/VNC/SSH on its own (inferred from draft).
- caveat: needs an external PostgreSQL database if the optional DB backend is used (inferred, the draft lists it as optional).
- caveat: default admin account (guacadmin) must be changed in the UI after first start (inferred).

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: guacamole
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/guacamole/guacamole:1.6.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/apache/guacamole-client/blob/0537c89cd783681b986ff8f8c4e0b97ec6873371/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/apache/guacamole-client)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://dlcdn.apache.org/guacamole/1.6.0/binary/guacamole-1.6.0.war)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Apache Guacamole client is a Java war built with maven and run in tomcat on jdk21. ContainerForge has java21, so tomcat and the war can go on containerforge-ubuntu, with the guacd daemon as a separate service. The main image is one process.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [guacamole/guacamole:1.6.0](https://hub.docker.com/r/guacamole/guacamole)
- **copy-from arm64**: [guacamole/guacamole:1.6.0](https://hub.docker.com/r/guacamole/guacamole)

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

❌ means it is missing too.

- **Dependency containers**: postgresql ✅, guacd (guacdImage) ❌
