## TODO: pin to version tag
FROM ghcr.io/trueforge-org/node:rolling@sha256:70adf71e6e9d204219ace16d177a96c7b06cc3d881c413eaaa312ed27d13479a

# set version label
ARG VERSION
ARG TARGETARCH
USER root
ARG PAIRDROP_RELEASE

# environment settings
ENV NODE_ENV="production"

RUN echo "**** install pairdrop ****" && \
  mkdir -p /app && \
  curl -o \
    /tmp/pairdrop.tar.gz -L \
    "https://github.com/schlagmichdoch/PairDrop/archive/refs/tags/${VERSION}.tar.gz" && \
  tar xf \
    /tmp/pairdrop.tar.gz -C \
    ./ --strip-components=1 && \
  cd /app && \
  chown -R apps:apps ./ && \
  su -s /bin/sh apps -c 'HOME=/tmp NODE_ENV=production npm ci' && \
  chown -R apps:apps /app && chmod -R 755 /app && \
  echo "**** cleanup ****" && \
  rm -rf \
    $HOME/.cache \
    /tmp/* \
    /tmp/.npm

# copy local files
USER apps
COPY . /


# ports and volumes
EXPOSE 3000
