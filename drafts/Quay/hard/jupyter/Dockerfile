# Row "jupyter-minimal" only. The other six rows wait for the user's decision on splitting (see plan.md section 2).
# UNVERIFIED: base image tag and digest are taken from the plan (same python base as apps/bazarr).
FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

# Upstream image tag, for example notebook-7.6.5
ARG VERSION

ENV JUPYTER_PORT=8888 \
    HOME=/config \
    JUPYTER_CONFIG_DIR=/config/.jupyter \
    JUPYTER_DATA_DIR=/config/.local/share/jupyter \
    JUPYTER_RUNTIME_DIR=/tmp/jupyter-runtime

USER root

# UNVERIFIED: check which of these packages the python base already ships before keeping them
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        git \
        less \
        nano-tiny \
        openssh-client \
        tzdata \
        unzip \
        vim-tiny \
        xclip && \
    rm -rf /var/lib/apt/lists/*

# The image tag is notebook-X.Y.Z and the PyPI package is X.Y.Z.
# UNVERIFIED: notebook 7.6.5 is the latest tag seen in the plan; confirm the pin with the user.
RUN /app/venv/bin/pip install --no-cache-dir "notebook==${VERSION#notebook-}" && \
    rm -rf /tmp/*

# UNVERIFIED: BSD-3-Clause license text from jupyter/docker-stacks is not yet shipped in /usr/share/licenses/jupyter/LICENSE

USER apps
COPY --chmod=0755 . /

WORKDIR /config

EXPOSE 8888

VOLUME /config

CMD ["/start.sh"]
