# guacamole

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: guacamole
- **Rows**: 1
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **Source repository**: https://github.com/apache/guacamole-client
- **Documentation**: https://guacamole.apache.org/doc/gug/

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

Other containers the chart needs (Chart.yaml dependencies, CNPG PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

❌ means it is missing too.

- **Dependency containers**: postgresql (CNPG) ✅, guacd (guacdImage) ❌
