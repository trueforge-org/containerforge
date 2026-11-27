FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

# set version label
ARG VERSION
USER root

# environment settings
ENV PYTHONUNBUFFERED=1 \
    PYTHONIOENCODING=utf-8

# UNVERIFIED: bcrypt, vobject and libpass wheels on Python 3.15 (amd64 and arm64) are not checked yet
RUN echo "**** install radicale ****" && \
  python3 -m venv /app/venv && \
  /app/venv/bin/pip install --no-cache-dir \
    "radicale[bcrypt]==${VERSION}" && \
  echo "**** install license ****" && \
  mkdir -p /usr/share/licenses/radicale && \
  curl -fsSL "https://raw.githubusercontent.com/Kozea/Radicale/v${VERSION}/COPYING.md" \
    -o /usr/share/licenses/radicale/COPYING.md && \
  echo "**** cleanup ****" && \
  chown -R apps:apps /app && \
  chmod -R 755 /app && \
  rm -rf \
    /tmp/* \
    $HOME/.cache

ENV HOME=/config \
    RADICALE_CONFIG=/config/config

# add local files
USER apps
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 5232
VOLUME /config

WORKDIR /config
