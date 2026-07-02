

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:a79e2182efe0bb3d2abd67d2bd445c8c5e2ecd1722ce0a59a678630ab5a4a80d AS alpine-buildstage


ARG VERSION
ARG TARGETARCH
USER root

RUN \
  echo "**** install build dependencies ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    build-essential && \
  echo "**** install unrar from source ****" && \
  mkdir /tmp/unrar && \
  curl -o \
    /tmp/unrar.tar.gz -L \
    "https://www.rarlab.com/rar/unrarsrc-${VERSION}.tar.gz" && \
  tar xf \
    /tmp/unrar.tar.gz -C \
    /tmp/unrar --strip-components=1 && \
  cd /tmp/unrar && \
  sed -i 's|LDFLAGS=-pthread|LDFLAGS=-pthread -static|' makefile && \
  sed -i 's|CXXFLAGS=-march=native |CXXFLAGS=|' makefile && \
  make && \
  install -v -m755 unrar /usr/bin && \
  echo "**** cleanup ****" && \
  apt-get autoremove -y && \
  rm -rf \
    /root/.cache \
    /tmp/*

# Storage layer consumed downstream
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:a79e2182efe0bb3d2abd67d2bd445c8c5e2ecd1722ce0a59a678630ab5a4a80d

ARG VERSION
ARG TARGETARCH
USER root

# Add files from buildstage
COPY --from=alpine-buildstage /usr/bin/unrar /usr/bin/unrar

USER apps
COPY --chmod=0755 . /

WORKDIR /config
VOLUME /config
