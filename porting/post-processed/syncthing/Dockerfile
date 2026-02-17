FROM ghcr.io/trueforge-org/golang:1.26.0 AS buildstage

# build variables
ARG VERSION
USER root

RUN \
 echo "**** install build packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    build-essential

RUN \
  echo "**** fetch source code ****" && \
  mkdir -p \
    /tmp/sync && \
  (curl -fL -o \
  /tmp/syncthing-src.tar.gz \
    "https://github.com/syncthing/syncthing/archive/refs/tags/v${VERSION}.tar.gz" || curl -fL -o \
  /tmp/syncthing-src.tar.gz \
    "https://github.com/syncthing/syncthing/archive/refs/tags/${VERSION}.tar.gz" || (SYNCTHING_RELEASE=$(curl -sX GET "https://api.github.com/repos/syncthing/syncthing/releases/latest" \
    | awk '/tag_name/{print $4;exit}' FS='[""]') && curl -fL -o \
  /tmp/syncthing-src.tar.gz \
    "https://github.com/syncthing/syncthing/archive/refs/tags/${SYNCTHING_RELEASE}.tar.gz") || curl -fL -o \
  /tmp/syncthing-src.tar.gz \
    "https://github.com/syncthing/syncthing/archive/refs/heads/main.tar.gz") && \
  tar xf \
  /tmp/syncthing-src.tar.gz -C \
    /tmp/sync --strip-components=1 && \
  echo "**** compile syncthing  ****" && \
  cd /tmp/sync && \
  go clean -modcache && \
  CGO_ENABLED=0 go run build.go \
    -no-upgrade \
    -version=v${VERSION} \
    build syncthing

############## runtime stage ##############
FROM ghcr.io/trueforge-org/ubuntu:24.04

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# environment settings
ENV HOME="/config"

RUN \
  echo "**** create var lib folder ****" && \
  install -d -o apps -g apps \
    /var/lib/syncthing

USER apps
COPY . /

# copy files from build stage and local files
COPY --from=buildstage /tmp/sync/syncthing /usr/bin/



# ports and volumes
EXPOSE 8384 22000/tcp 22000/udp 21027/UDP
VOLUME /config

WORKDIR /config
