# Initial draft from plan.md. Not built or tested.
# OPEN (plan sections 3 and 10): web layer (gunicorn only here, or an nginx/openresty front), process supervisor, and port 4848 vs 8080.
# TODO (plan section 1): upstream FFmpeg download is incomplete (FFMPEG_DATE and SHA256_FFMPEG_* are undefined upstream). Not added yet.

############## build ##############
FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d AS build

ARG VERSION
# UNVERIFIED: the source tarball has no published checksum. Compute and pin it (self-computed).
ARG SHA256_SOURCE=""

USER root

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      ca-certificates \
      curl; \
    rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    mkdir -p /tmp/src; \
    curl -fL -o /tmp/tubesync.tar.gz "https://github.com/meeb/tubesync/archive/refs/tags/v${VERSION}.tar.gz"; \
    echo "${SHA256_SOURCE}  /tmp/tubesync.tar.gz" | sha256sum -c -; \
    tar xzf /tmp/tubesync.tar.gz -C /tmp/src --strip-components=1; \
    rm -f /tmp/tubesync.tar.gz

# The venv is built at its final path (/app/venv), because venv scripts keep absolute shebangs.
# UNVERIFIED: requirements file name. Upstream uses pipenv or uv (plan section 4, step 3).
RUN set -eux; \
    python -m venv /app/venv; \
    PIP_NO_CACHE_DIR=1 PIP_CACHE_DIR=/tmp/pip-cache /app/venv/bin/pip install -r /tmp/src/requirements.txt

############## runtime ##############
FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

ARG VERSION

USER root

# TODO (UNVERIFIED): ffmpeg and ffprobe are required (plan section 4, step 4). The asset name, date and sha256 are not in the plan.
# yt-dlp is not pinned yet (plan section 10).

COPY --from=build /tmp/src /app/tubesync
COPY --from=build /app/venv /app/venv

RUN set -eux; \
    mkdir -p /usr/share/licenses/tubesync; \
    cp /app/tubesync/LICENSE /usr/share/licenses/tubesync/LICENSE

ENV PYTHONPATH=/app/tubesync \
    HOME=/config \
    XDG_CONFIG_HOME=/config/tubesync \
    XDG_STATE_HOME=/config/state \
    XDG_CACHE_HOME=/tmp/cache \
    SQLITE_TMPDIR=/tmp/cache \
    PYTHONPYCACHEPREFIX=/tmp/pycache \
    DENO_DIR=/tmp/deno \
    S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0

USER apps
COPY --chmod=0755 . /

EXPOSE 4848

VOLUME /config
VOLUME /downloads
WORKDIR /config
