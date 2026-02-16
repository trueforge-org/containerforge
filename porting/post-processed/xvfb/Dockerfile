FROM ghcr.io/trueforge-org/ubuntu:24.4@sha256:0628c88c702e66783b5565dadf138d0f878ee3c5e8ef8fc7c52b28224ae4d174 AS builder

COPY /patches /patches
ENV PATCH_VERSION=21 \
    APT_BRANCH=3.22-stable \
    HOME=/config

RUN \
  echo "**** build deps ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    build-essential 

RUN \
  echo "**** setup abuild ****" && \
  sed '/SUDO=/d' -i /usr/bin/abuild-keygen && \
  abuild-keygen --install -n 

RUN \
  echo "**** get and build apt-get build ****" && \
  abuild-keygen -a -n && \
  git clone \
    --depth 1 \
    --branch ${APT_BRANCH} \
    https://gitlab.alpinelinux.org/alpine/aports.git && \
  cd aports/community/xorg-server/ && \
  cp \
    /patches/${PATCH_VERSION}-xvfb-dri3.patch \
    patch.patch && \
  sed -i \
    's|\.tar\.xz"|\.tar\.xz\npatch.patch"|' \
    APTBUILD && \
  sed -i \
    '/^sha512sums="/,/"$/{ s|\(  .*\.tar\.xz\)|\1\n'"$(sha512sum patch.patch)"'|; }' \
    APTBUILD && \
  abuild -F -r || : && \
  tar -xf /config/packages/community/*/xvfb*.apt-get && \
  mkdir -p /build-out/usr/bin && \
  mv usr/bin/Xvfb /build-out/usr/bin/


# runtime stage
FROM ghcr.io/trueforge-org/ubuntu:24.4@sha256:0628c88c702e66783b5565dadf138d0f878ee3c5e8ef8fc7c52b28224ae4d174
ARG VERSION
ARG TARGETARCH
USER root
COPY --from=builder /build-out /
USER apps
COPY . /

WORKDIR /config
VOLUME /config
