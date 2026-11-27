# jupyter/docker-stacks Dockerfiles (pinned commits)

Source URL(s): raw variants of
- 3b8a7969348b2c0cc6d597188f662fdb2a73616e/images/{minimal-notebook,pyspark-notebook,r-notebook,scipy-notebook,tensorflow-notebook}/Dockerfile
- fe190c9e10d341558f637d9e7c2e2dff6145ef6b/images/{all-spark-notebook,datascience-notebook}/Dockerfile
(fetched 2026-11-27; comments and blank lines stripped by grep; full files not saved)

## Common pattern (all)
- ARG REGISTRY=quay.io, OWNER=jupyter, BASE_IMAGE=$REGISTRY/$OWNER/<parent>; FROM $BASE_IMAGE
- SHELL bash -o pipefail ; USER root for apt, then USER ${NB_UID} for mamba. Ends with rm -rf ~/.cache, fix-permissions.

## Per image
| Image | Parent | Key installs | Notes |
| --- | --- | --- | --- |
| minimal-notebook | base-notebook | apt: curl git nano-tiny tzdata unzip vim-tiny openssh-client less texlive-* xclip | nano via update-alternatives; COPY Rprofile.site, setup-scripts |
| scipy-notebook | minimal-notebook | apt build-essential, cm-super, dvipng, ffmpeg; mamba: many scipy stack pkgs (pandas, scikit-learn, etc.) | matplotlib Agg check |
| r-notebook | minimal-notebook | apt fonts-dejavu unixodbc r-cran-rodbc gfortran gcc; mamba r-base + tidyverse etc. | |
| tensorflow-notebook | scipy-notebook | mamba jupyter-server-proxy; pip tensorflow (-cpu suffix on x86_64) | COPY cuda/20tensorboard-proxy-env.sh to before-notebook.d |
| pyspark-notebook | scipy-notebook | apt openjdk-17-jre-headless ; ARG spark_version, hadoop_version=3, scala_version ; setup_spark.py ; SPARK_HOME=/usr/local/spark | EXPOSE 4040 ; spark_download_url dlcdn.apache.org |
| all-spark-notebook | pyspark-notebook | protobuf-java jar (sha256 checked) ; apt fonts-dejavu gfortran gcc ; mamba r-base, r-sparklyr etc. | R_LIBS_USER=${SPARK_HOME}/R/lib |
| datascience-notebook | scipy-notebook | apt fonts-dejavu gfortran gcc ; setup_julia.py ; setup-julia-packages.bash ; mamba R packages + rpy2 | JULIA_DEPOT_PATH=/opt/julia |
| base-notebook (fe190c9e) | docker-stacks-foundation | apt pandoc, fonts-liberation, run-one ; mamba jupyterlab, notebook>=7.2.2, nbclassic, jupyterhub-singleuser | see separate section |

## base-notebook (fe190c9e, used as chart's default image, see medium/jupyter)
- ENV JUPYTER_PORT=8888 ; EXPOSE $JUPYTER_PORT ; CMD ["start-notebook.py"]
- COPY start-notebook.py start-notebook.sh start-singleuser.py start-singleuser.sh to /usr/local/bin/ ; jupyter_server_config.py docker_healthcheck.py to /etc/jupyter/
- HEALTHCHECK --interval=3s --timeout=1s --start-period=3s --retries=3 CMD ["/etc/jupyter/docker_healthcheck.py"]
- Final USER ${NB_UID}, WORKDIR ${HOME}.

## Gotchas
- Parent images resolve via quay.io/jupyter/*; chart pins digests for notebook-7.4.7.
