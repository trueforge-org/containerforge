
FROM ghcr.io/trueforge-org/ubuntu:24.4 AS buildstage

ARG VERSION
ARG TARGETARCH

USER root

RUN echo "**** ingest external assets ****" && \
  mkdir -p /build-out/qemu /build-out/usr/bin /tmp/qemu && \
  curl -L -o /tmp/qemu.deb \
    "http://deb.debian.org/debian/pool/main/q/qemu/qemu-user_${VERSION}_${TARGETARCH}.deb" && \
  cd /tmp && \
  dpkg-deb -R qemu.deb /tmp/qemu && \
  cp /tmp/qemu/usr/bin/* /build-out/qemu && \
  curl -L -o /build-out/usr/bin/qemu-binfmt-conf \
    "https://raw.githubusercontent.com/qemu/qemu/${VERSION}/scripts/qemu-binfmt-conf.sh" && \
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
