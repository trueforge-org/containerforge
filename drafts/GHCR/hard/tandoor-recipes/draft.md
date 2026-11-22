# tandoor-recipes

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: hard
- **Chart**: tandoor-recipes
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: yes (postgresql)
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/tandoor-recipes
- **Source repository**: https://github.com/TandoorRecipes/recipes
- **Documentation**: https://docs.tandoor.dev/
- **Website**: https://tandoor.dev

## Potentially relevant resources

- **Container image**: https://ghcr.io/tandoorrecipes/recipes
- **Source code repository**: https://github.com/TandoorRecipes/recipes/pkgs/container/recipes

## Base container

- **Foundation**: ubuntu (`ghcr.io/trueforge-org/ubuntu:26.4`), which every ContainerForge runtime image is built on
- **Runtime image**: python
- **Alternative runtime image**: nginx
- **Reason**: Django app on Python, run with gunicorn and nginx together.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: tandoor-recipes
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/tandoorrecipes/recipes:2.7.6`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/TandoorRecipes/recipes/blob/89c07f26bb168221e41d409224976960cf344289/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/TandoorRecipes/recipes)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/TandoorRecipes/recipes/releases/tag/2.7.6)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Tandoor is a Django app with a Vue frontend built in a node stage. Upstream runs gunicorn and nginx together, and it needs Postgres from PostgreSQL. Several processes and the frontend build make this a large port even though the code is interpreted.

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

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

- **Dependency containers**: postgresql ✅
