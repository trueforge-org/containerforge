# github.com/jupyter/docker-stacks (repo README)

Source URL(s): https://github.com/jupyter/docker-stacks (WebFetch, fetched 2026-11-27). Alternative to api.github.com/repos/jupyter/docker-stacks, which returned "API rate limit exceeded".

- Images referenced: base-notebook, scipy-notebook, datascience-notebook, pytorch-notebook, tensorflow-notebook. Selection guide is a separate docs page (not fetched).
- Registry: quay.io (pushed there since 2023-10-20). Docker Hub copies are old and not updated.
- Start: example `docker run -p 10000:8888 quay.io/jupyter/scipy-notebook:2026-07-28` (JupyterLab, container 8888).
- Root dir override: start-notebook.py --ServerApp.root_dir=/home/jovyan/work.
- Switch frontend: env DOCKER_STACKS_JUPYTER_CMD=notebook.
- NB_UID / NB_USER defaults: not stated. Healthcheck: not mentioned.
