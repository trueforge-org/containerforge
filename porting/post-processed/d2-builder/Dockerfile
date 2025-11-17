
FROM ghcr.io/trueforge-org/ubuntu:24.4

# set version label
ARG VERSION
ARG TARGETARCH
USER root

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
  S6_VERBOSITY=2

RUN \
  echo "**** install packages ****" && \
  apk add -U --upgrade --no-cache \
    git \
    grep && \
  echo "**** install d2 ****" && \
  mkdir -p /tmp/d2 /output /work && \
  curl -o \
    /tmp/d2.tar.gz -L \
    "https://github.com/terrastruct/d2/releases/download/v${VERSION}/d2-v${VERSION}-linux-$TARGETARCH.tar.gz" && \
  tar xzf \
  /tmp/d2.tar.gz -C \
    /tmp/d2 --strip-components=1 && \
  cp /tmp/d2/bin/d2 /usr/local/bin && \
  printf "Version: v${VERSION}\nBuild-date: ${BUILD_DATE}" > /build_version && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/*

# copy local files
USER apps
COPY . /
COPY ./root /

ENTRYPOINT ["/init-d2"]
