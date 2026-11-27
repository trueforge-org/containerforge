# stay on python 3.14 until appdaemon supports 3.15 (upstream requires-python <3.15)
FROM ghcr.io/trueforge-org/python:3.14.8@sha256:f099b700b824b7760cb846418f84a2c14c2f04992320506ab3ca5b79d3ac1232

ARG VERSION

ENV HOME=/config

USER root

# appdaemon is a pure Python wheel, installed into the base venv at build time only.
# UNVERIFIED: cp314 wheels exist for every dependency; add build tools here if a source build appears.
RUN set -eux; \
    /app/venv/bin/pip install --no-cache-dir "appdaemon==${VERSION}"; \
    mkdir -p /usr/share/licenses/appdaemon; \
    curl -fsSLo /usr/share/licenses/appdaemon/LICENSE.md \
        "https://raw.githubusercontent.com/AppDaemon/appdaemon/${VERSION}/LICENSE.md"; \
    chown -R root:root /app; \
    chmod -R 755 /app; \
    rm -rf /root/.cache /tmp/*

USER apps
COPY --chmod=0755 . /

EXPOSE 5050
VOLUME /config
WORKDIR /config
