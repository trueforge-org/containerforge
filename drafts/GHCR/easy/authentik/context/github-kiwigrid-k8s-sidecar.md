# kiwigrid/k8s-sidecar 2.14.3 (chart sidecar image)
Source URL(s): https://raw.githubusercontent.com/kiwigrid/k8s-sidecar/2.14.3/Dockerfile (fetched; blob variant same). Repo page not fetched.

- Base: `python:3.14.10-alpine3.24` (digest pinned), base stage installs libcrypto3 / libssl3 (pinned 3.5.9-r0)
- Builder: venv, `pip install .` from pyproject.toml/src; gcc + musl-dev pinned in builder stage only
- Runtime: `USER 65534:65534`, `ENV PYTHONUNBUFFERED=1`, `WORKDIR /app`, venv at /app/.venv on PATH
- `ENTRYPOINT ["python", "-u", "-m", "sidecar"]`
- LABEL licenses=MIT, source https://github.com/kiwigrid/k8s-sidecar
- No EXPOSE, no VOLUME, no HEALTHCHECK
- Note: plan says apps/k8s-sidecar already exists (not built here)
