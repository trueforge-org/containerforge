## TODO: pin to version tag
FROM ghcr.io/trueforge-org/node:rolling@sha256:5623d300a3daef923e94ff2a518468f381105886e35f8562868a3ceb7ebe39c9

# set version label
ARG VERSION
ARG TARGETARCH
USER root
ARG PAIRDROP_RELEASE

# environment settings
ENV NODE_ENV="production"

RUN echo "**** install pairdrop ****" && \
  mkdir -p /app/pairdrop && \
  if [ -z ${PAIRDROP_RELEASE} ]; then \
    PAIRDROP_RELEASE=$(curl -sL "https://api.github.com/repos/schlagmichdoch/pairdrop/tags" \
    | jq -r '.[0].name'); \
  fi && \
  curl -o \
    /tmp/pairdrop.tar.gz -L \
    "https://github.com/schlagmichdoch/PairDrop/archive/refs/tags/${PAIRDROP_RELEASE}.tar.gz" && \
  tar xf \
    /tmp/pairdrop.tar.gz -C \
    /app/pairdrop/ --strip-components=1 && \
  cd /app/pairdrop && \
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
