FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION
USER root

ENV \
  HOME=/config \
  NPM_CONFIG_CACHE=/tmp/npm \
  PORT=8000 \
  DATABASE=/config/.dizquetv

# UNVERIFIED: ffmpeg version pin from the plan; check `apt-cache policy ffmpeg` at build time
RUN echo "*** Installing ffmpeg ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends ffmpeg=7:8.0.1-3ubuntu2 && \
  rm -rf /var/lib/apt/lists/*

# Built from source on the base image Node; upstream publishes no npm package and only a Node 12 nexe binary (x64)
# UNVERIFIED: no checksum is published upstream for the tag tarball
RUN echo "*** Installing dizqueTV ${VERSION} ***" && \
  mkdir -p /app/dizquetv && \
  curl -fsSL -o /tmp/dizquetv.tar.gz \
    "https://github.com/vexorian/dizquetv/archive/refs/tags/${VERSION}.tar.gz" && \
  tar xzf /tmp/dizquetv.tar.gz -C /app/dizquetv --strip-components=1 && \
  cd /app/dizquetv && \
  npm install --no-audit --no-fund && \
  npm run build && \
  npm prune --omit=dev && \
  install -d /usr/share/licenses/dizquetv && \
  cp /app/dizquetv/LICENSE /usr/share/licenses/dizquetv/ && \
  echo "*** Cleaning Up ***" && \
  chown -R apps:apps /app && chmod -R 755 /app && \
  rm -rf /tmp/dizquetv.tar.gz /tmp/npm

USER apps
COPY --chmod=0755 . /

WORKDIR /config

EXPOSE 8000

VOLUME /config
