FROM ghcr.io/trueforge-org/node:24.19.0@sha256:225eb6fc544ed2a7e052fc90395181505b118b0a0c5547b18e1b0207937843ba

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
