FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

ARG VERSION

ENV \
  PYTHONUNBUFFERED=1 \
  PYTHONPATH=/app/invitarr

USER root

# discord.py 2.x compatibility patch for app/bot/cogs/app.py and run.py at ce30f13.
COPY scripts/invitarr-compat.patch /tmp/invitarr-compat.patch

# UNVERIFIED: discord.py 2.7.1 and PlexAPI 4.18.3 on Python 3.15 (wheel or build not checked).
# UNVERIFIED: `patch` is present in the python base (plan says via dpkg-dev).
RUN set -eux; \
    mkdir -p /app/invitarr /usr/share/licenses/invitarr; \
    curl -fsSL "https://github.com/Sleepingpirates/Invitarr/archive/${VERSION}.tar.gz" | tar xz -C /app/invitarr --strip-components=1; \
    cd /app/invitarr; \
    patch -p1 < /tmp/invitarr-compat.patch; \
    cp /app/invitarr/LICENSE /usr/share/licenses/invitarr/LICENSE; \
    /app/venv/bin/pip install --no-cache-dir "discord.py==2.7.1" "PlexAPI==4.18.3" texttable python-dotenv; \
    chown -R apps:apps /app; \
    chmod -R 755 /app; \
    rm -rf /tmp/*

USER apps
COPY --chmod=0755 . /

VOLUME /config

WORKDIR /config
