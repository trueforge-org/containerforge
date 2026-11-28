# Source: the original xXGuhuXx/auto-yt-dl repo is gone (404). This builds the GPL-3.0 fork
# CDeLeon94/auto-yt-dl (branch "latest") pinned to one commit. See plan.md "Fix attempt".
FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

ARG VERSION
ARG COMMIT
ARG SOURCE_SHA256
ARG FLASK_VERSION
ARG PYTUBE_VERSION

USER root
WORKDIR /app

# The upstream publishes no checksum, so SOURCE_SHA256 is the hash of the pinned commit tarball.
# Upstream pins Flask 2.0.1 and pytube~=11.0.0 on Python 3.8, replaced here by versions that run on this Python.
# hadolint ignore=DL3013
RUN set -eux; \
    curl -fsSL -o /tmp/src.tar.gz "https://github.com/CDeLeon94/auto-yt-dl/archive/${COMMIT}.tar.gz"; \
    echo "${SOURCE_SHA256}  /tmp/src.tar.gz" | sha256sum -c -; \
    mkdir /tmp/src; \
    tar -xzf /tmp/src.tar.gz -C /tmp/src --strip-components=1; \
    cp -r /tmp/src/app.py /tmp/src/main.py /tmp/src/pytubDef /tmp/src/static /tmp/src/templates /app/; \
    mkdir -p /usr/share/licenses/auto-yt-dl; \
    cp /tmp/src/LICENSE /usr/share/licenses/auto-yt-dl/LICENSE; \
    pip install --no-cache-dir "Flask==${FLASK_VERSION}" "pytube==${PYTUBE_VERSION}"; \
    chown -R root:root /app; \
    chmod -R a+rX /app; \
    rm -rf /tmp/* /var/tmp/* /root/.cache

USER apps
COPY --chmod=0755 . /

# The app uses paths relative to its working directory (data/ and Downloads/), so it runs from /config.
WORKDIR /config
VOLUME ["/config"]

EXPOSE 5000

CMD ["/start.sh"]
