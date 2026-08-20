FROM ghcr.io/trueforge-org/node:24.19.0@sha256:e4a650bed011451239955d1f33ed35b5fe0e849a9a28d55fd8fb9f03439b27fd

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
