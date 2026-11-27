FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

ARG VERSION

ENV HOME=/config \
    PIP_CACHE_DIR=/tmp/pip \
    FLASK_APP=main.py \
    PYTHONUNBUFFERED=1

USER root
WORKDIR /app

# ffmpeg is a tool, not the app, so the pin only guards reproducibility.
# UNVERIFIED: ffmpeg 7:8.0.1-3ubuntu2 is still in the ubuntu archive at build time
# hadolint ignore=DL3008
RUN apt-get update && \
    apt-get install -y --no-install-recommends ffmpeg=7:8.0.1-3ubuntu2 && \
    rm -rf /var/lib/apt/lists/*

# Source tarball (no checksum is published upstream)
RUN set -eux; \
    curl -fsSL -o /tmp/clipplex.tar.gz "https://github.com/jo-nike/clipplex/archive/refs/tags/${VERSION}.tar.gz"; \
    tar -xzf /tmp/clipplex.tar.gz -C /app --strip-components=1; \
    rm -f /tmp/clipplex.tar.gz /app/Dockerfile /app/example.gif; \
    rm -rf /app/app/static/media; \
    ln -s /config/media /app/app/static/media; \
    mkdir -p /usr/share/licenses/clipplex; \
    cp /app/LICENSE /usr/share/licenses/clipplex/

# Python dependencies go into the base image venv at build time (never at runtime).
# UNVERIFIED: upstream pins (Flask 2.0.2, Werkzeug 2.0.0, Jinja2 3.0, flask_wtf 0.14.3) are not kept, because they are unlikely to import on Python 3.15.
# requests and ffmpeg-python keep their upstream pins.
RUN /app/venv/bin/pip install \
        flask \
        flask-wtf \
        requests==2.26.0 \
        ffmpeg-python==0.2.0 && \
    /app/venv/bin/python -c "import flask, flask_wtf, ffmpeg, requests" && \
    chown -R root:root /app && \
    chmod -R go=rX /app && \
    rm -rf /tmp/pip /tmp/*

USER apps
COPY --chmod=0755 . /

EXPOSE 5000
VOLUME /config
VOLUME /media
