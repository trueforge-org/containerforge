FROM ghcr.io/trueforge-org/golang:rolling@sha256:ac65e5c170bd1414782d964689f53a0f72f7e07567c212e666652e86a6ec26e5 AS buildstage

# build variables

RUN \
 echo "**** install build packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    build-essential

RUN \
  echo "**** fetch source code ****" && \
  mkdir -p \
    /tmp/sync && \
  curl -o \
  /tmp/syncthing-src.tar.gz -L \
    "https://github.com/syncthing/syncthing/archive/v${VERSION}.tar.gz" && \
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
FROM ghcr.io/trueforge-org/ubuntu:24.4@sha256:0628c88c702e66783b5565dadf138d0f878ee3c5e8ef8fc7c52b28224ae4d174

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# environment settings
ENV HOME="/config"

RUN \
  echo "**** create var lib folder ****" && \
  install -d -o apps -g apps \
    /var/lib/syncthing && \

USER apps
COPY . /

# copy files from build stage and local files
COPY --from=buildstage /tmp/sync/syncthing /usr/bin/



# ports and volumes
EXPOSE 8384 22000/tcp 22000/udp 21027/UDP
VOLUME /config

WORKDIR /config
