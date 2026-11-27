FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

ARG VERSION
ARG JUPYTERLAB_VERSION

ENV JUPYTER_PORT=8888

USER root

# Install notebook and JupyterLab into the base venv at build time; caches stay in /tmp.
# Upstream base-notebook also installs pandoc, fonts-liberation and run-one. Not ported (see PR notes).
RUN set -eux; \
    pip install uv; \
    UV_CACHE_DIR=/tmp/uv-cache uv pip install --python /app/venv/bin/python \
        "notebook==${VERSION}" \
        "jupyterlab==${JUPYTERLAB_VERSION}"; \
    pip uninstall --yes uv; \
    rm -rf /tmp/* /root/.cache; \
    /app/venv/bin/python -m pip check

# UNVERIFIED: dist-info licenses path for the pinned notebook release
RUN set -eux; \
    mkdir -p /usr/share/licenses/jupyter; \
    cp /app/venv/lib/python*/site-packages/notebook-*.dist-info/licenses/* /usr/share/licenses/jupyter/

USER apps
COPY --chmod=0755 . /

WORKDIR /config

EXPOSE 8888

CMD [""]
