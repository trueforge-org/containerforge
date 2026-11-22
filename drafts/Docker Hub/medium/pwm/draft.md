# pwm

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: pwm
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/pwm
- **Source repository**: https://github.com/pwm-project/pwm
- **Website**: https://pwm-project.org/

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/fjudith/pwm

## Base container

- **Primary**: java8
- **Alternative**: none
- **Reason**: The input names java8 for a Java WAR run in a servlet container.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: pwm
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/fjudith/pwm:alpine`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/fjudith/pwm-container/blob/a011fb616d0a963ba60fe4f71056a0be5d34a78d/alpine/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/pwm-project/pwm)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/pwm-project/pwm/releases/download/v2_0_8/pwm-onejar-2.0.8.jar)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Java web app (PWM) built as a WAR with maven, then deployed in tomcat on jre8 alpine. ContainerForge has java8, so tomcat and the war can go on containerforge-ubuntu under /app with config in /config. One process, but the tomcat setup adds moving parts.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: no
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
