FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

ARG VERSION

ENV \
    HOME=/config \
    XDG_CACHE_HOME=/tmp/.cache \
    PIP_NO_CACHE_DIR=1

USER root
WORKDIR /app

# UNVERIFIED: Python 3.15 is not a declared target of glances 4.5.9 and psutil
# wheels for 3.15 are not confirmed. Fallback base: ghcr.io/trueforge-org/python:3.14.8
RUN set -eux; \
    /app/venv/bin/pip install --no-cache-dir "glances[web]==${VERSION}"; \
    mkdir -p /usr/share/licenses/glances; \
    curl -fsSL -o /usr/share/licenses/glances/COPYING \
      "https://raw.githubusercontent.com/nicolargo/glances/v${VERSION}/COPYING"; \
    chown -R root:root /app; \
    chmod -R 755 /app; \
    rm -rf /root/.cache /tmp/*

USER apps
COPY --chmod=0755 . /
WORKDIR /config

EXPOSE 61208

VOLUME /config
