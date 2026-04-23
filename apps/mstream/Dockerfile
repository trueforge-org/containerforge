FROM ghcr.io/trueforge-org/node:24.15.0@sha256:b28543555508c7c4b954b4eb0e3b04e0c20958c14b1cd080aeda2ad0bb3187fa

# set version label
ARG VERSION
ARG TARGETARCH
USER root

ENV HOME="/config"

RUN \
  echo "**** install runtime packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    openssl && \
  echo "**** install app ****" && \
  mkdir -p \
    /app/mstream && \
  (curl -fL -o \
    /tmp/mstream.tar.gz \
    "https://github.com/IrosTheBeggar/mStream/archive/refs/tags/v${VERSION}.tar.gz" || curl -fL -o \
    /tmp/mstream.tar.gz \
    "https://github.com/IrosTheBeggar/mStream/archive/refs/tags/${VERSION}.tar.gz") && \
  tar xzf \
    /tmp/mstream.tar.gz -C \
    /app/mstream/ --strip-components=1 && \
  cd /app/mstream && \
  npm install --omit=dev && \
  chown -R apps:apps ./ && \
  npm link && \
  echo "**** cleanup ****" && \
  rm -rf /app/mstream/save/sync && \
  ln -s /config/sync /app/mstream/save/sync && \
  apt-get autoremove -y && \
  rm -rf \
    $HOME/.cache \
    $HOME/.npm \
    /tmp/* \
    /tmp/.npm

# add local files
USER apps
COPY --chmod=0755 . /


# ports and volumes
EXPOSE 3000
VOLUME /config

WORKDIR /config
