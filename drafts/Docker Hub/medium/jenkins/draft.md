# jenkins

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: jenkins
- **Rows**: 1
- **Hard dependency containers**: no
- **Soft dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **Source repository**: https://github.com/jenkinsci/jenkins
- **Documentation**: https://www.jenkins.io/doc/

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: jenkins
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/jenkins/jenkins:2.544-jdk17`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/jenkinsci/docker/blob/2.544/debian/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/jenkinsci/jenkins)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://updates.jenkins.io/download/war/2.544/jenkins.war)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Jenkins war downloaded from get.jenkins.io and pinned by version, run on a Java 17 runtime that the java17 sibling covers. JENKINS_HOME maps to /config and plugin installs write there. The war is arch-neutral, so the image is a download plus a java run.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.
- A trailing `*` means the claim could not be confirmed against the upstream source, so it is a best judgement and should be rechecked before porting.

- **amd64**: yes*
- **arm64**: yes*

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [jenkins/jenkins:2.544-jdk17](https://hub.docker.com/r/jenkins/jenkins)
- **copy-from arm64**: [jenkins/jenkins:2.544-jdk17](https://hub.docker.com/r/jenkins/jenkins)

### Dependency containers

- **Dependency containers**: none
