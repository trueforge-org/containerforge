# jupyter

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Quay
- **Difficulty**: medium
- **Chart**: jupyter
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: yes (minimal-notebook, r-notebook, scipy-notebook, tensorflow-notebook, datascience-notebook, pyspark-notebook, all-spark-notebook)
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/jupyter
- **Source repository**: https://github.com/jupyter/notebook
- **Documentation**: https://docs.jupyter.org/en/latest/

## Potentially relevant resources

- **Source code repository**: https://github.com/jupyter/docker-stacks
- **Container image**: https://quay.io/jupyter/all-spark-notebook
- **Container image**: https://quay.io/jupyter/base-notebook
- **Container image**: https://quay.io/jupyter/datascience-notebook
- **Container image**: https://quay.io/jupyter/minimal-notebook
- **Container image**: https://quay.io/jupyter/pyspark-notebook
- **Container image**: https://quay.io/jupyter/r-notebook
- **Container image**: https://quay.io/jupyter/scipy-notebook
- **Container image**: https://quay.io/jupyter/tensorflow-notebook

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: jupyter
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `quay.io/jupyter/base-notebook:notebook-7.4.7`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/jupyter/docker-stacks/blob/fe190c9e10d341558f637d9e7c2e2dff6145ef6b/images/base-notebook/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/jupyter/notebook)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: binary: `pip:notebook`

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: JupyterLab installed with mamba and pip on top of docker-stacks, which starts as the jovyan user with root-based start scripts. Port by installing notebook and JupyterLab with pip into /app, moving the home directory to /config, and dropping the sudo-based startup.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [quay.io/jupyter/base-notebook:notebook-7.4.7](https://quay.io/repository/jupyter/base-notebook)
- **copy-from arm64**: [quay.io/jupyter/base-notebook:notebook-7.4.7](https://quay.io/repository/jupyter/base-notebook)

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

❌ means it is missing too.

- **Dependency containers**: minimal-notebook (minimalImage) ❌, r-notebook (rImage) ❌, scipy-notebook (scipyImage) ❌, tensorflow-notebook (tensorflowImage) ❌, datascience-notebook (datascienceImage) ❌, pyspark-notebook (pysparkImage) ❌, all-spark-notebook (allsparkImage) ❌
