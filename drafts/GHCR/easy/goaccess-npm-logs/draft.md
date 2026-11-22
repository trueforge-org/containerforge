# goaccess-npm-logs

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: easy
- **Chart**: goaccess-npm-logs
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/goaccess-npm-logs
- **Source repository**: https://github.com/allinurl/goaccess
- **Documentation**: https://goaccess.io/man
- **Website**: https://goaccess.io/

## Potentially relevant resources

- **Container image**: https://ghcr.io/xavier-hernandez/goaccess-for-nginxproxymanager
- **Source code repository**: https://github.com/xavier-hernandez/goaccess-for-nginxproxymanager

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: goaccess-npm-logs
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/xavier-hernandez/goaccess-for-nginxproxymanager:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/xavier-hernandez/goaccess-for-nginxproxymanager/blob/6044a67020e04752f962a76f95ff99f6cdb00701/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/allinurl/goaccess)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: binary: `apt:goaccess`

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: GoAccess is packaged in the Ubuntu archive, so it installs with one apt command, and the wrapper just adds scripts for Nginx Proxy Manager logs. Read logs from a shared volume and write reports to /config or /tmp, with no services or root needed.

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
