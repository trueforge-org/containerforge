# Only the application source is taken from the upstream image. Its runtime is not used.
ARG VERSION
FROM docker.io/jsavargas/telethon_downloader:${VERSION} AS upstream

FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d
ARG VERSION

ENV \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    HOME=/config \
    PIP_CACHE_DIR=/tmp/pip \
    XDG_CACHE_HOME=/tmp/.cache

USER root
WORKDIR /app

# ffmpeg is used by yt-dlp and for media handling. unzip is already in the base image.
RUN apt-get update && apt-get install -y --no-install-recommends \
        ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# Application source (app.py, modules, requirements.txt) from the upstream image.
# UNVERIFIED for 4.0.15: the file layout was not inspected.
COPY --from=upstream /app/ /app/telethon/

# Install Python dependencies into the bundled venv, then make the code read-only.
# UNVERIFIED: the upstream requirements (unpinned) were not tested on Python 3.15.
RUN /app/venv/bin/pip install --no-cache-dir -r /app/telethon/requirements.txt \
    && chown -R root:root /app/telethon \
    && chmod -R 755 /app/telethon

# License: not included in the upstream /app copy, so fetch it from the upstream commit
# the source above matches. There is no git tag, so update this commit on each version bump.
RUN mkdir -p /usr/share/licenses/telethon-downloader \
    && curl -fsSL "https://raw.githubusercontent.com/jsavargas/telethon_downloader/ed9710a358ef6da97107073e64e6ae66e6ac2aff/License.md" \
        -o /usr/share/licenses/telethon-downloader/License.md \
    && rm -rf /tmp/* /tmp/.cache

# Mount points for downloads and torrent watch folder, owned by the runtime user.
RUN mkdir -p /config /download /watch \
    && chown apps:apps /config /download /watch

USER apps
COPY --chmod=0755 . /
WORKDIR /config

VOLUME /config /download /watch

CMD [""]
