# jupyter/docker-stacks images/base-notebook/Dockerfile (fe190c9e10d341558f637d9e7c2e2dff6145ef6b)

Source URL(s): https://github.com/jupyter/docker-stacks/blob/fe190c9e.../images/base-notebook/Dockerfile and raw variant (fetched 2026-11-27)

## Build
- ARG REGISTRY=quay.io, OWNER=jupyter; BASE_IMAGE=$REGISTRY/$OWNER/docker-stacks-foundation (FROM $BASE_IMAGE)
- USER root: apt-get install fonts-liberation, pandoc, run-one ; clean apt lists.
- USER ${NB_UID}, WORKDIR /tmp: mamba install jupyterhub-singleuser, jupyterlab, nbclassic, notebook>=7.2.2 ; jupyter server --generate-config ; mamba clean ; jupyter lab clean ; fix-permissions CONDA_DIR and /home/${NB_USER}.

## Runtime
- ENV JUPYTER_PORT=8888 ; EXPOSE $JUPYTER_PORT
- CMD ["start-notebook.py"]
- COPY start-notebook.py, start-notebook.sh, start-singleuser.py, start-singleuser.sh -> /usr/local/bin/
- COPY jupyter_server_config.py, docker_healthcheck.py -> /etc/jupyter/ ; fix-permissions /etc/jupyter/ (root step)
- HEALTHCHECK --interval=3s --timeout=1s --start-period=3s --retries=3 CMD ["/etc/jupyter/docker_healthcheck.py"]
- USER ${NB_UID} at end ; WORKDIR ${HOME}

## Gotchas
- Pins notebook>=7.2.2 because newer jupyterlab can lag notebook.
- Healthcheck works for lab, notebook, nbclassic, server, retro commands.
