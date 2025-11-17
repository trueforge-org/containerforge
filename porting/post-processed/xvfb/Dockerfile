FROM ghcr.io/trueforge-org/ubuntu:24.4@sha256:c0d65e9793c7c477d7c27c7936d9aa40dad9a404fdf49f1cfdd69da7220988bb AS builder

COPY /patches /patches
ENV PATCH_VERSION=21 \
    APK_BRANCH=3.22-stable \
    HOME=/config

RUN \
  echo "**** build deps ****" && \
  apk add \
    alpine-sdk 

RUN \
  echo "**** setup abuild ****" && \
  sed '/SUDO=/d' -i /usr/bin/abuild-keygen && \
  abuild-keygen --install -n 

RUN \
  echo "**** get and build apkbuild ****" && \
  abuild-keygen -a -n && \
  git clone \
    --depth 1 \
    --branch ${APK_BRANCH} \
    https://gitlab.alpinelinux.org/alpine/aports.git && \
  cd aports/community/xorg-server/ && \
  cp \
    /patches/${PATCH_VERSION}-xvfb-dri3.patch \
    patch.patch && \
  sed -i \
    's|\.tar\.xz"|\.tar\.xz\npatch.patch"|' \
    APKBUILD && \
  sed -i \
    '/^sha512sums="/,/"$/{ s|\(  .*\.tar\.xz\)|\1\n'"$(sha512sum patch.patch)"'|; }' \
    APKBUILD && \
  abuild -F -r || : && \
  tar -xf /config/packages/community/*/xvfb*.apk && \
  mkdir -p /build-out/usr/bin && \
  mv usr/bin/Xvfb /build-out/usr/bin/


# runtime stage
FROM ghcr.io/trueforge-org/ubuntu:24.4@sha256:c0d65e9793c7c477d7c27c7936d9aa40dad9a404fdf49f1cfdd69da7220988bb
ARG VERSION
ARG TARGETARCH
USER root
COPY --from=builder /build-out /
