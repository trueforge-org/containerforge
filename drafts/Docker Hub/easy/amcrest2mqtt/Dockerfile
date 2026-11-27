FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

ARG VERSION

USER root
WORKDIR /app

# Pure-Python dependencies only, so no apt packages are needed.
# UNVERIFIED: runtime behaviour on Python 3.15 (upstream pins Python 3.9 and 2021-2022 libraries).
RUN set -eux; \
    mkdir -p /app/amcrest2mqtt /usr/share/licenses/amcrest2mqtt; \
    curl -fsSL -o /tmp/app.tar.gz "https://github.com/dchesterton/amcrest2mqtt/archive/refs/tags/${VERSION}.tar.gz"; \
    tar xzf /tmp/app.tar.gz -C /app/amcrest2mqtt --strip-components=1; \
    /app/venv/bin/pip install --no-cache-dir -r /app/amcrest2mqtt/requirements.txt; \
    cp /app/amcrest2mqtt/LICENSE /usr/share/licenses/amcrest2mqtt/LICENSE; \
    chown -R root:root /app/amcrest2mqtt; chmod -R a+rX /app/amcrest2mqtt; \
    rm -rf /tmp/* /root/.cache

USER apps
COPY --chmod=0755 . /

WORKDIR /config
VOLUME /config
