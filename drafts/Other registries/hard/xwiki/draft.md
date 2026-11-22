# xwiki

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Other registries
- **Difficulty**: hard
- **Chart**: xwiki
- **Rows**: 1
- **Hard dependency containers**: yes (postgresql)
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/xwiki
- **Source repository**: https://github.com/xwiki/xwiki-platform
- **Documentation**: https://www.xwiki.org/xwiki/bin/view/Documentation/
- **Website**: https://www.xwiki.org/xwiki/bin/view/Main/WebHome

## Potentially relevant resources

- **Container image**: https://gallery.ecr.aws/docker/library/xwiki
- **Source code repository**: https://github.com/xwiki/xwiki-docker

## Base container

- **Primary**: java25
- **Alternative**: none
- **Reason**: Tomcat on JRE 25 running an XWiki WAR.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: xwiki
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `public.ecr.aws/docker/library/xwiki:18.9.0-postgres-tomcat`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/xwiki/xwiki-docker/blob/589e96c134218b1e1d6dab64865aade428ae1106/18/postgres-tomcat/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/xwiki/xwiki-platform)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://maven.xwiki.org/releases/org/xwiki/platform/xwiki-platform-distribution-war/18.9.0/xwiki-platform-distribution-war-18.9.0.war)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Tomcat 10 on JRE 25 with an XWiki WAR, a PostgreSQL JDBC jar and a LibreOffice tarball for document conversion, so several services and a large Java stack. The WAR and JDBC jar are arch-neutral, but LibreOffice and the Tomcat layout need reworking for read-only /app.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [public.ecr.aws/docker/library/xwiki:18.9.0-postgres-tomcat](https://gallery.ecr.aws/docker/library/xwiki)
- **copy-from arm64**: [public.ecr.aws/docker/library/xwiki:18.9.0-postgres-tomcat](https://gallery.ecr.aws/docker/library/xwiki)

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

- **Dependency containers**: postgresql ✅
