
FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

ARG VERSION
USER root

ENV \
  HOME=/config \
  UV_CACHE_DIR=/tmp/uv \
  PIP_CACHE_DIR=/tmp/pip \
  MPLCONFIGDIR=/tmp/matplotlib \
  UV_PYTHON_INSTALL_DIR=/usr/local/share/uv-python \
  PATH=/app/cq-venv/bin:$PATH

# cadquery 2.2.0b0 needs Python <3.11, so a separate Python 3.10 is installed with uv.
# UNVERIFIED: the GL/X11 package set the OCP wheel needs on this Ubuntu release.
# hadolint ignore=DL3008
RUN apt-get update && apt-get install -y --no-install-recommends \
      libgl1 \
      libglu1-mesa \
      libxrender1 \
      libxext6 \
      libsm6 \
  && rm -rf /var/lib/apt/lists/*

RUN pip install uv \
  && uv python install 3.10 \
  && uv venv --python 3.10 /app/cq-venv \
  && uv pip install --python /app/cq-venv/bin/python "cadquery-server[cadquery]==${VERSION}" \
  && pip uninstall --yes uv \
  && rm -rf /root/.cache /tmp/* \
  && chown -R root:root /app/cq-venv && chmod -R 755 /app/cq-venv

# UNVERIFIED: the license is downloaded from the git tag (the wheel may not ship LICENSE)
RUN mkdir -p /usr/share/licenses/cadquery-server \
  && curl -fsSL -o /usr/share/licenses/cadquery-server/LICENSE \
    "https://raw.githubusercontent.com/roipoussiere/cadquery-server/${VERSION}/LICENSE"

COPY --chmod=0755 . /

USER apps

EXPOSE 5000

VOLUME /config
