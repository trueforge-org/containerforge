# modsecurity-crs

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: modsecurity-crs
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/modsecurity-crs
- **Source repository**: https://github.com/coreruleset/coreruleset
- **Documentation**: https://www.coreruleset.org/docs/
- **Website**: https://www.coreruleset.org

## Potentially relevant resources

- **Source code repository**: https://github.com/coreruleset/modsecurity-crs-docker
- **Container image**: https://hub.docker.com/r/owasp/modsecurity-crs

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: modsecurity-crs
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/owasp/modsecurity-crs:3.3.4-apache-202307110507`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/coreruleset/modsecurity-crs-docker/blob/0148a7443cfa92c9d229b546c89378f548f45410/apache/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/coreruleset/coreruleset)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: binary: `apt:libapache2-mod-security2`

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Apache httpd with ModSecurity and the OWASP CRS rules. The upstream image compiles ModSecurity 2.9.7, but Ubuntu's apt libapache2-mod-security2 and the CRS release tarball can replace that build, so the rework is config and packaging.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [owasp/modsecurity-crs:3.3.4-apache-202307110507](https://hub.docker.com/r/owasp/modsecurity-crs)
- **copy-from arm64**: [owasp/modsecurity-crs:3.3.4-apache-202307110507](https://hub.docker.com/r/owasp/modsecurity-crs)

### Dependency containers

- **Dependency containers**: none
