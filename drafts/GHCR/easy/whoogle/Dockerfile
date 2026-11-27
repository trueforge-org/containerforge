# syntax=docker/dockerfile:1@sha256:572cebbc2b15e6f84c077742952674889cb63cd5e9b80abdffcbe587b6f19183
# Upstream: https://github.com/benbusby/whoogle-search (archived; last release v1.2.4)

FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d
ARG VERSION
# UNVERIFIED: sha256 of https://github.com/benbusby/whoogle-search/archive/refs/tags/v1.2.4.tar.gz is not published upstream. Compute it and pin here before the build.
ARG WHOOGLE_SHA256=""

ENV \
    CONFIG_VOLUME=/config \
    EXPOSE_PORT=5000 \
    APP_ROOT=/app/whoogle/app \
    WHOOGLE_TOR_SERVICE=0

USER root
WORKDIR /app

# Download the upstream source tag and verify it
RUN curl -fsSL -o /tmp/whoogle.tar.gz "https://github.com/benbusby/whoogle-search/archive/refs/tags/v${VERSION}.tar.gz" \
    && echo "${WHOOGLE_SHA256}  /tmp/whoogle.tar.gz" | sha256sum -c - \
    && mkdir -p /app/whoogle \
    && tar -xzf /tmp/whoogle.tar.gz -C /app/whoogle --strip-components=1 \
    && rm -f /tmp/whoogle.tar.gz

# Install the pinned runtime requirements into the base interpreter (same approach as apps/bazarr)
# UNVERIFIED: native wheels (cryptography, pyOpenSSL, brotli, cffi) for the 3.15 base are not confirmed.
RUN python3 -m pip install --no-cache-dir -r /app/whoogle/requirements.txt

# Keep the licence, then prune everything the runtime does not need
RUN install -Dm0644 /app/whoogle/LICENSE /usr/share/licenses/whoogle/LICENSE \
    && cd /app/whoogle \
    && rm -rf test docs charts letsencrypt heroku.yml app.json docker-compose*.yaml LICENSE \
    && chown -R root:root /app && chmod -R 755 /app \
    && rm -rf /root/.cache /tmp/*

USER apps
COPY --chmod=0755 . /
WORKDIR /app/whoogle

EXPOSE 5000
VOLUME /config
