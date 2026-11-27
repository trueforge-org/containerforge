# Initial draft from drafts/Docker Hub/medium/metatube/plan.md. Not built yet.
# Built from source: the upstream image (jvt038/metatube) is stale and amd64-only.

FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

ARG VERSION
ARG TARGETARCH
USER root

ENV PORT=5000 \
    HOST=0.0.0.0 \
    FFMPEG=/usr/bin \
    DOWNLOADS=/downloads \
    DATABASE_URL=sqlite:////config/app.db \
    PIP_CACHE_DIR=/tmp/pip \
    HOME=/config

RUN echo "**** install runtime packages ****" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        ffmpeg \
        libmagic1 && \
    rm -rf /var/lib/apt/lists/*
# UNVERIFIED: the python base may already provide some of these. Check before the first build.

RUN echo "**** download metatube ****" && \
    mkdir -p /app/metatube /downloads /tmp/metatube && \
    curl -fL -o /tmp/metatube.tar.gz \
        "https://github.com/JVT038/MetaTube/archive/${VERSION}.tar.gz" && \
    tar xzf /tmp/metatube.tar.gz -C /app/metatube --strip-components=1 && \
    rm -f /tmp/metatube.tar.gz
# UNVERIFIED: VERSION is a short commit SHA. Replace it with the full 40-character SHA before merge.

RUN echo "**** install python dependencies into the read-only venv ****" && \
    /app/venv/bin/pip install --no-cache-dir -r /app/metatube/requirements.txt
# UNVERIFIED: requirements.txt on Python 3.15 (upstream image uses 3.12).

RUN echo "**** prepare writable paths and license ****" && \
    mkdir -p /config/migrations /usr/share/licenses/metatube && \
    ln -sfn /config/migrations /app/metatube/migrations && \
    cp /app/metatube/LICENSE /usr/share/licenses/metatube/LICENSE && \
    chown apps:apps /config /downloads && \
    chown -R apps:apps /app/metatube && \
    chmod -R 755 /app/metatube && \
    rm -rf /tmp/*

USER apps
COPY --chmod=0755 . /

EXPOSE 5000
VOLUME ["/config", "/downloads"]
