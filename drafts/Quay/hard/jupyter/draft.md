# jupyter

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Quay
- **Difficulty**: hard
- **Chart**: jupyter
- **Rows**: 7
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- Row 1: **Chart**: jupyter
- Row 1: **Role**: sidecar (allsparkImage)
- Row 2: **Chart**: jupyter
- Row 2: **Role**: sidecar (datascienceImage)
- Row 3: **Chart**: jupyter
- Row 3: **Role**: sidecar (minimalImage)
- Row 4: **Chart**: jupyter
- Row 4: **Role**: sidecar (pysparkImage)
- Row 5: **Chart**: jupyter
- Row 5: **Role**: sidecar (rImage)
- Row 6: **Chart**: jupyter
- Row 6: **Role**: sidecar (scipyImage)
- Row 7: **Chart**: jupyter
- Row 7: **Role**: sidecar (tensorflowImage)

### Container

The image and tag the chart uses today.

- Row 1: **Container**: `quay.io/jupyter/all-spark-notebook:notebook-7.4.7`
- Row 2: **Container**: `quay.io/jupyter/datascience-notebook:notebook-7.4.7`
- Row 3: **Container**: `quay.io/jupyter/minimal-notebook:notebook-7.4.7`
- Row 4: **Container**: `quay.io/jupyter/pyspark-notebook:notebook-7.4.7`
- Row 5: **Container**: `quay.io/jupyter/r-notebook:notebook-7.4.7`
- Row 6: **Container**: `quay.io/jupyter/scipy-notebook:notebook-7.4.7`
- Row 7: **Container**: `quay.io/jupyter/tensorflow-notebook:notebook-7.4.7`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- Row 1: **Dockerfile**: [Dockerfile](https://github.com/jupyter/docker-stacks/blob/fe190c9e10d341558f637d9e7c2e2dff6145ef6b/images/all-spark-notebook/Dockerfile)
- Row 2: **Dockerfile**: [Dockerfile](https://github.com/jupyter/docker-stacks/blob/fe190c9e10d341558f637d9e7c2e2dff6145ef6b/images/datascience-notebook/Dockerfile)
- Row 3: **Dockerfile**: [Dockerfile](https://github.com/jupyter/docker-stacks/blob/3b8a7969348b2c0cc6d597188f662fdb2a73616e/images/minimal-notebook/Dockerfile)
- Row 4: **Dockerfile**: [Dockerfile](https://github.com/jupyter/docker-stacks/blob/3b8a7969348b2c0cc6d597188f662fdb2a73616e/images/pyspark-notebook/Dockerfile)
- Row 5: **Dockerfile**: [Dockerfile](https://github.com/jupyter/docker-stacks/blob/3b8a7969348b2c0cc6d597188f662fdb2a73616e/images/r-notebook/Dockerfile)
- Row 6: **Dockerfile**: [Dockerfile](https://github.com/jupyter/docker-stacks/blob/3b8a7969348b2c0cc6d597188f662fdb2a73616e/images/scipy-notebook/Dockerfile)
- Row 7: **Dockerfile**: [Dockerfile](https://github.com/jupyter/docker-stacks/blob/3b8a7969348b2c0cc6d597188f662fdb2a73616e/images/tensorflow-notebook/Dockerfile)

### Application source

The application's own source repository or project page.

- Row 1: **Application source**: [source](https://github.com/jupyter/docker-stacks)
- Row 2: **Application source**: [source](https://github.com/jupyter/docker-stacks)
- Row 3: **Application source**: [source](https://github.com/jupyter/docker-stacks)
- Row 4: **Application source**: [source](https://github.com/jupyter/docker-stacks)
- Row 5: **Application source**: [source](https://github.com/jupyter/docker-stacks)
- Row 6: **Application source**: [source](https://github.com/jupyter/docker-stacks)
- Row 7: **Application source**: [source](https://github.com/jupyter/docker-stacks)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- Row 1: **Application binary**: binary: `pip:notebook`
- Row 2: **Application binary**: binary: `pip:notebook`
- Row 3: **Application binary**: binary: `pip:notebook`
- Row 4: **Application binary**: binary: `pip:notebook`
- Row 5: **Application binary**: binary: `pip:notebook`
- Row 6: **Application binary**: binary: `pip:notebook`
- Row 7: **Application binary**: binary: `pip:notebook`

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- Row 1: **Difficulty**: hard
- Row 2: **Difficulty**: hard
- Row 3: **Difficulty**: hard
- Row 4: **Difficulty**: hard
- Row 5: **Difficulty**: hard
- Row 6: **Difficulty**: hard
- Row 7: **Difficulty**: hard

### Reason

- Row 1: **Reason**: Layered docker-stacks Jupyter image (conda/mamba, many Python/scientific packages, extra languages) on Ubuntu 26.04 base; a large stack with a long layer chain that needs home dir redirected to /config for rootless/read-only. Adds Spark, R and Scala/Toree kernels on top of pyspark: Java plus Spark plus R, very heavy.
- Row 2: **Reason**: Layered docker-stacks Jupyter image (conda/mamba, many Python/scientific packages, extra languages) on Ubuntu 26.04 base; a large stack with a long layer chain that needs home dir redirected to /config for rootless/read-only. Adds Julia and R kernels via mamba on top of scipy.
- Row 3: **Reason**: Layered docker-stacks Jupyter image (conda/mamba, many Python/scientific packages, extra languages) on Ubuntu 26.04 base; a large stack with a long layer chain that needs home dir redirected to /config for rootless/read-only. Smallest of the chain: git, nbconvert tools and LaTeX bits on base-notebook; ContainerForge python-node base could serve.
- Row 4: **Reason**: Layered docker-stacks Jupyter image (conda/mamba, many Python/scientific packages, extra languages) on Ubuntu 26.04 base; a large stack with a long layer chain that needs home dir redirected to /config for rootless/read-only. Adds Apache Spark and Java 17+ via release tarball on scipy.
- Row 5: **Reason**: Layered docker-stacks Jupyter image (conda/mamba, many Python/scientific packages, extra languages) on Ubuntu 26.04 base; a large stack with a long layer chain that needs home dir redirected to /config for rootless/read-only. Adds R and IRkernel via mamba on minimal.
- Row 6: **Reason**: Layered docker-stacks Jupyter image (conda/mamba, many Python/scientific packages, extra languages) on Ubuntu 26.04 base; a large stack with a long layer chain that needs home dir redirected to /config for rootless/read-only. Adds the scientific Python stack (numpy, pandas, matplotlib etc.) on minimal.
- Row 7: **Reason**: Layered docker-stacks Jupyter image (conda/mamba, many Python/scientific packages, extra languages) on Ubuntu 26.04 base; a large stack with a long layer chain that needs home dir redirected to /config for rootless/read-only. Adds TensorFlow via pip on scipy; large wheels.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- Row 1: **amd64**: yes
- Row 1: **arm64**: yes
- Row 2: **amd64**: yes
- Row 2: **arm64**: yes
- Row 3: **amd64**: yes
- Row 3: **arm64**: yes
- Row 4: **amd64**: yes
- Row 4: **arm64**: yes
- Row 5: **amd64**: yes
- Row 5: **arm64**: yes
- Row 6: **amd64**: yes
- Row 6: **arm64**: yes
- Row 7: **amd64**: yes
- Row 7: **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- Row 1: **copy-from amd64**: [quay.io/jupyter/all-spark-notebook:notebook-7.4.7](https://quay.io/repository/jupyter/all-spark-notebook)
- Row 1: **copy-from arm64**: [quay.io/jupyter/all-spark-notebook:notebook-7.4.7](https://quay.io/repository/jupyter/all-spark-notebook)
- Row 2: **copy-from amd64**: [quay.io/jupyter/datascience-notebook:notebook-7.4.7](https://quay.io/repository/jupyter/datascience-notebook)
- Row 2: **copy-from arm64**: [quay.io/jupyter/datascience-notebook:notebook-7.4.7](https://quay.io/repository/jupyter/datascience-notebook)
- Row 3: **copy-from amd64**: [quay.io/jupyter/minimal-notebook:notebook-7.4.7](https://quay.io/repository/jupyter/minimal-notebook)
- Row 3: **copy-from arm64**: [quay.io/jupyter/minimal-notebook:notebook-7.4.7](https://quay.io/repository/jupyter/minimal-notebook)
- Row 4: **copy-from amd64**: [quay.io/jupyter/pyspark-notebook:notebook-7.4.7](https://quay.io/repository/jupyter/pyspark-notebook)
- Row 4: **copy-from arm64**: [quay.io/jupyter/pyspark-notebook:notebook-7.4.7](https://quay.io/repository/jupyter/pyspark-notebook)
- Row 5: **copy-from amd64**: [quay.io/jupyter/r-notebook:notebook-7.4.7](https://quay.io/repository/jupyter/r-notebook)
- Row 5: **copy-from arm64**: [quay.io/jupyter/r-notebook:notebook-7.4.7](https://quay.io/repository/jupyter/r-notebook)
- Row 6: **copy-from amd64**: [quay.io/jupyter/scipy-notebook:notebook-7.4.7](https://quay.io/repository/jupyter/scipy-notebook)
- Row 6: **copy-from arm64**: [quay.io/jupyter/scipy-notebook:notebook-7.4.7](https://quay.io/repository/jupyter/scipy-notebook)
- Row 7: **copy-from amd64**: [quay.io/jupyter/tensorflow-notebook:notebook-7.4.7](https://quay.io/repository/jupyter/tensorflow-notebook)
- Row 7: **copy-from arm64**: [quay.io/jupyter/tensorflow-notebook:notebook-7.4.7](https://quay.io/repository/jupyter/tensorflow-notebook)

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, CNPG PostgreSQL, sidecars).

- Row 1: **Dependency containers**: -
- Row 2: **Dependency containers**: -
- Row 3: **Dependency containers**: -
- Row 4: **Dependency containers**: -
- Row 5: **Dependency containers**: -
- Row 6: **Dependency containers**: -
- Row 7: **Dependency containers**: -
