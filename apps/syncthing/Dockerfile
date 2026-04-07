FROM ghcr.io/trueforge-org/golang:1.26.0@sha256:48b8c4f16a22d675e504971c7a18b5384346a081b4c2f031923eb23f16c7d68d AS buildstage

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
FROM ghcr.io/trueforge-org/ubuntu:24.04@sha256:cc82810600df75ed627ea3453ff80a6fc5204ea48139834e41f0c74e685ef776

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
COPY --chmod=0755 . /

# copy files from build stage and local files
COPY --from=buildstage /tmp/sync/syncthing /usr/bin/



# ports and volumes
EXPOSE 8384 22000/tcp 22000/udp 21027/UDP
VOLUME /config

WORKDIR /config
