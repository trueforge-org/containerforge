FROM ghcr.io/trueforge-org/node:24.16.0@sha256:a08c30dfdd0b43d6df28ed1489b98399cb7aa476212199b8369ac04acb1ae1de

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
  echo "**** install runtime packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    nginx \
    tftp-hpa && \
  echo "**** install build packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    npm && \
  echo "**** install WebApp ****" && \
  (curl -fL -o \
  /tmp/webapp.tar.gz \
    "https://github.com/netbootxyz/webapp/archive/refs/tags/${VERSION}.tar.gz" || curl -fL -o \
  /tmp/webapp.tar.gz \
    "https://github.com/netbootxyz/webapp/archive/refs/tags/v${VERSION}.tar.gz") && \
  tar xf \
  /tmp/webapp.tar.gz -C \
    /app/ --strip-components=1 && \
  npm install --prefix /app && \
  echo "**** cleanup ****" && \
  apt-get autoremove -y && \
  rm -rf \
    /tmp/*

# copy local files
USER apps
COPY --chmod=0755 . /


# app runs on port 3000
EXPOSE 3000

VOLUME /config

WORKDIR /config
