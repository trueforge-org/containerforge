FROM ghcr.io/trueforge-org/golang:1.26.2@sha256:ad85bce6a931f436c6e3395e2253e3c6bcc8094c050091ae802d13402bcb625f as migrationbuilder
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

FROM ghcr.io/trueforge-org/golang:1.26.2@sha256:ad85bce6a931f436c6e3395e2253e3c6bcc8094c050091ae802d13402bcb625f as binbuilder
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

FROM ghcr.io/trueforge-org/node:24.15.0@sha256:4bca93d03032d86c7fe416b234838df556eb5d945e1d716dfc98b8fff38470ad as nodebuilder

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
FROM ghcr.io/trueforge-org/python:3.14.4@sha256:f7d559cef2b714762b919fffffabb8892824a30cb61e3df293dcad6851a29a3b

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
