FROM ghcr.io/trueforge-org/node:24.22.0@sha256:dcc5de347a84bfe9e114478ef48d5dfecb83c740b4e732930b9b451e56b1a4f8

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# environment settings
ENV NODE_ENV="production"

RUN echo "**** install pairdrop ****" && \
  mkdir -p /app && \
  (curl -fL -o \
    /tmp/pairdrop.tar.gz -L \
    "https://github.com/schlagmichdoch/PairDrop/archive/refs/tags/v${VERSION}.tar.gz" || curl -fL -o \
    /tmp/pairdrop.tar.gz \
    "https://github.com/schlagmichdoch/PairDrop/archive/refs/heads/main.tar.gz") && \
  tar xf \
    /tmp/pairdrop.tar.gz -C \
    /app --strip-components=1 && \
  cd /app && \
  npm ci --omit=dev && \
  chown -R apps:apps /app && chmod -R 755 /app && \
  echo "**** cleanup ****" && \
  rm -rf \
    $HOME/.cache \
    /tmp/* \
    /tmp/.npm

# copy local files
USER apps
COPY --chmod=0755 . /


# ports and volumes
EXPOSE 3000

WORKDIR /config
VOLUME /config
