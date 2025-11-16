
FROM ghcr.io/trueforge-org/ubuntu:24.4 AS buildstage


USER root

RUN \
  echo "**** install build deps ****" && \
  apt-get update && \
  apt-get install -y \
    curl \
    xz-utils

RUN \
  echo "**** ingest external assets ****" && \
  mkdir -p \
    /build-out/qemu \
    /build-out/usr/bin \
    /tmp/qemu && \
  if [ -z "${VERSION}" ]; then \
    VERSION=$(curl -sX GET https://deb.debian.org/debian/dists/bookworm-backports/main/binary-$TARGETARCH/Packages.xz | xz -dc |grep -A 7 -m 2 'Package: qemu-user$' | awk -F ': ' '/Version/{print $2;exit}' | awk -F ':' '{print $2}'); \
  fi && \
  curl -o \
    /tmp/qemu.deb -L \
    "http://deb.debian.org/debian/pool/main/q/qemu/qemu-user_${VERSION}_$TARGETARCH.deb" && \
  cd /tmp && \
  dpkg-deb -R \
    qemu.deb \
    /tmp/qemu && \
  cp \
    /tmp/qemu/usr/bin/* \
    /build-out/qemu && \
  curl -o \
    /build-out/usr/bin/qemu-binfmt-conf -L \
    "https://raw.githubusercontent.com/qemu/qemu/refs/heads/master/scripts/qemu-binfmt-conf.sh" && \
  chmod +x /build-out/usr/bin/qemu-binfmt-conf

# runtime stage
FROM ghcr.io/trueforge-org/ubuntu:24.4

# set version label
ARG VERSION

USER apps

# Add build assets
COPY --from=buildstage /build-out/ /

# add local files
COPY . /
