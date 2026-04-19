FROM ghcr.io/trueforge-org/node:24.15.0@sha256:c7c4a7a0c399c025cd2677db6215cf530d7e18e51b8461a0b449bcac85ccbf3b

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
