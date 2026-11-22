# gaseous-server

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: gaseous-server
- **Rows**: 1
- **Hard dependency containers**: yes (one of: mariadb, mysql)
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/gaseous-server
- **Source repository**: https://github.com/gaseous-project/gaseous-server
- **Documentation**: https://github.com/gaseous-project/gaseous-server/wiki

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/gaseousgames/gaseousserver

## Base container

- **Primary**: ubuntu
- **Alternative**: none
- **Reason**: ASP.NET Core 8 app with the dotnet runtime added on ubuntu.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: gaseous-server
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/gaseousgames/gaseousserver:v1.7.14`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/gaseous-project/gaseous-server/blob/139459c1e4d989772545ca5da8cf36aaee215a3b/build/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/gaseous-project/gaseous-server)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: ASP.NET Core 8 app published with dotnet in an sdk stage, then run on the aspnet runtime. ContainerForge has no .NET app, so the dotnet 8 runtime must be added on containerforge-ubuntu. The app uses mariadb, which ContainerForge already has.

### amd64 / arm64

How we get the application for that architecture.

- `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.

- **amd64**: compile
- **arm64**: compile

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [gaseousgames/gaseousserver:v1.7.14](https://hub.docker.com/r/gaseousgames/gaseousserver)
- **copy-from arm64**: [gaseousgames/gaseousserver:v1.7.14](https://hub.docker.com/r/gaseousgames/gaseousserver)

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

- **Dependency containers**: mariadb ✅
