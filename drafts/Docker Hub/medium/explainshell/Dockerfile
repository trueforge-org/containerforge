# UNVERIFIED: cmarkgfm and bashlex wheels for Python 3.15 on amd64 and arm64; add a compiler only if a wheel is missing
FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

# set version label
ARG VERSION
ARG TARGETARCH
# baked database asset from the upstream db-latest release; renovate cannot track it, bump by hand
ARG DB_NAME=explainshell-2026-06-22-063435.db.zst
ARG DB_SHA256=9c6286d533f7f52e07b2420555b9cff93cf4754380c379747166e1f20374ebc6
USER root

ENV HOME=/tmp \
    DEBUG=false \
    DB_PATH=/app/explainshell.db \
    GIT_SHA=${VERSION}

RUN \
  echo "**** install build packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    zstd && \
  echo "**** download source ****" && \
  mkdir -p /app/explainshell-src /usr/share/licenses/explainshell && \
  curl -fL -o /tmp/explainshell-src.tar.gz \
    "https://github.com/idank/explainshell/archive/${VERSION}.tar.gz" && \
  tar xzf /tmp/explainshell-src.tar.gz -C /app/explainshell-src --strip-components=1 && \
  echo "**** install python requirements ****" && \
  /app/venv/bin/pip install --no-cache-dir --no-warn-script-location \
    -r /app/explainshell-src/requirements.txt && \
  echo "**** fetch and verify database ****" && \
  curl -fL -o /tmp/explainshell.db.zst \
    "https://github.com/idank/explainshell/releases/download/db-latest/${DB_NAME}" && \
  echo "${DB_SHA256}  /tmp/explainshell.db.zst" | sha256sum -c - && \
  zstd -d /tmp/explainshell.db.zst -o /app/explainshell.db && \
  sha256sum /app/explainshell.db | cut -d' ' -f1 > /app/explainshell.db.sha256 && \
  echo "**** install license ****" && \
  cp /app/explainshell-src/LICENSE /usr/share/licenses/explainshell/LICENSE && \
  echo "**** cleanup ****" && \
  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    zstd && \
  apt-get clean && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* && \
  install -d -o apps -g apps /config

# add local files
USER apps
COPY --chmod=0755 . /

# ports and volumes
WORKDIR /app/explainshell-src
EXPOSE 8080
VOLUME /config

CMD ["/start.sh"]
