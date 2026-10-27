FROM ghcr.io/trueforge-org/golang:1.27.3@sha256:a510ab4fec09e8fc886a7d8dc005211b2c44a96a5d1a2b94f3c5e75ea7baa2ca as migrationbuilder
USER root

RUN \
  echo "**** build fs-repo-migrations ****" && \
  mkdir -p /build-out/usr/bin && \
  git clone https://github.com/ipfs/fs-repo-migrations.git && \
  cd fs-repo-migrations && \
  for BUILD in fs-repo-migrations fs-repo-12-to-13 fs-repo-13-to-14 fs-repo-14-to-15; do \
    cd ${BUILD} && \
    go build && \
    mv fs-repo-* /build-out/usr/bin/ && \
    cd .. ; \
  done

FROM ghcr.io/trueforge-org/golang:1.27.3@sha256:a510ab4fec09e8fc886a7d8dc005211b2c44a96a5d1a2b94f3c5e75ea7baa2ca as binbuilder
USER root

RUN \
  echo "**** build nestool ****" && \
  mkdir -p /build-out/usr/local/bin && \
  git clone https://github.com/Kreeblah/NES20Tool.git && \
  cd NES20Tool && \
  go build && \
  mv NES20Tool /build-out/usr/local/bin

RUN \
  echo "**** grab binmerge ****" && \
  BINMERGE_RELEASE=$(curl -sX GET "https://api.github.com/repos/putnam/binmerge/releases/latest" \
    | awk '/tag_name/{print $4;exit}' FS='[""]') && \
  curl -o \
    /tmp/binmerge.tar.gz -L \
    "https://github.com/putnam/binmerge/archive/${BINMERGE_RELEASE}.tar.gz" && \
  tar xf \
    /tmp/binmerge.tar.gz -C \
    /tmp/ --strip-components=1 && \
  chmod +x /tmp/binmerge && \
  mv /tmp/binmerge /build-out/usr/local/bin

RUN \
  echo "**** build fs-repo-migrations ****" && \
  mkdir /build-out/usr/bin && \
  git clone https://github.com/ipfs/fs-repo-migrations.git && \
  cd fs-repo-migrations && \
  for BUILD in fs-repo-migrations fs-repo-12-to-13 fs-repo-13-to-14 fs-repo-14-to-15; do \
    cd ${BUILD} && \
    go build && \
    mv fs-repo-* /build-out/usr/bin/ && \
    cd .. ; \
  done

FROM ghcr.io/trueforge-org/node:24.22.1@sha256:5b3efcfc48aa4e5f4a21e1e77615662772c45561c4021f663f456fc3227b5955 as nodebuilder

USER root
ARG VERSION

RUN \
  echo "**** install build packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    p7zip-full \
    zip && \
  rm -rf /var/lib/apt/lists/*

RUN \
  echo "**** grab emulatorjs ****" && \
  mkdir /emulatorjs && \
  curl -o \
    /tmp/emulatorjs.tar.gz -L \
    "https://github.com/linuxserver/emulatorjs/archive/${VERSION}.tar.gz" && \
  tar xf \
    /tmp/emulatorjs.tar.gz -C \
    /emulatorjs/ --strip-components=1

RUN \
  echo "**** grab emulatorjs blobs ****" && \
  curl -o \
    /tmp/emulatorjs-blob.tar.gz -L \
    "https://github.com/thelamer/emulatorjs/archive/main.tar.gz" && \
  tar xf \
    /tmp/emulatorjs-blob.tar.gz -C \
    /emulatorjs/frontend/ --strip-components=1

RUN \
  echo "**** grab libretro blobs ****" && \
  curl -o \
    /tmp/custom-cores.tar.gz -L \
    "https://github.com/linuxserver/libretro-cores/archive/master.tar.gz" && \
  tar xf \
    /tmp/custom-cores.tar.gz -C \
    /emulatorjs/frontend/ --strip-components=1 && \
  rm /emulatorjs/frontend/README.md

RUN \
  echo "**** build emulatorjs ****" && \
  cd /emulatorjs && \
  npm install

# runtime stage
FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
  echo "**** install runtime packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    file \
    flac \
    libcap2-bin \
    nginx \
    nodejs \
    p7zip-full \
    python3 \
    libsdl2-2.0-0 && \
  apt-get install -y --no-install-recommends \
    mame-tools && \
  mkdir -p /data && \
  echo "**** allow non-root nginx to bind low ports ****" && \
  setcap 'cap_net_bind_service=+ep' /usr/sbin/nginx && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* && \
  rm -rf /var/lib/apt/lists/*

# add local files and files from buildstage
COPY --from=binbuilder /build-out/ /
COPY --from=migrationbuilder /build-out/ /
COPY --from=nodebuilder /emulatorjs/ /emulatorjs/
USER apps
COPY --chmod=0755 . /
COPY --chmod=0755 root/ /


# ports
EXPOSE 80 3000

WORKDIR /config
VOLUME /config
