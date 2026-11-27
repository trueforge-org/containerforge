# stay on python 3.14 until all pinned wheels (psycopg2-binary, aiohttp, pymongo) ship cp315
FROM ghcr.io/trueforge-org/python:3.14.8@sha256:f099b700b824b7760cb846418f84a2c14c2f04992320506ab3ca5b79d3ac1232

ARG VERSION
USER root

ENV \
  PYTHONDONTWRITEBYTECODE=1 \
  PYTHONUNBUFFERED=1

# Source tarball has no published checksum, so integrity rests on the git tag over HTTPS.
# requirements.txt pins exact versions. All dependencies ship manylinux wheels, so no apt packages are needed.
RUN set -eux; \
  echo "*** Installing DiscordGSM ***"; \
  curl -fsSL -o /tmp/discordgsm.tar.gz \
    "https://github.com/DiscordGSM/GameServerMonitor/archive/refs/tags/${VERSION}.tar.gz"; \
  mkdir -p /app; \
  tar xzf /tmp/discordgsm.tar.gz -C /app --strip-components=1; \
  /app/venv/bin/pip install --no-cache-dir -r /app/requirements.txt; \
  rm -rf /app/data; \
  ln -s /config/data /app/data; \
  mkdir -p /usr/share/licenses/discordgsm; \
  cp /app/LICENSE /usr/share/licenses/discordgsm/LICENSE; \
  chown -R apps:apps /app; \
  chmod -R 755 /app; \
  rm -rf /tmp/* /root/.cache

USER apps
COPY --chmod=0755 . /

VOLUME /config
