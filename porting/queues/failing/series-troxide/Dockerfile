# buildstage
FROM ghcr.io/trueforge-org/ubuntu:24.04 as buildstage

RUN \
  echo "**** install build deps ****" && \
  apt-get update && \
  apt-get install -y \
    build-essential \
    libgtk-3-dev \
    libssl-dev \
    openssl \
    pkg-config && \
  echo "**** install rust ****" && \
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs > rustup.sh && \
  sh rustup.sh -y

ENV PATH="/root/.cargo/bin:${PATH}"

RUN \
  echo "**** build binary ****" && \
  cargo install series-troxide

# runtime
FROM ghcr.io/trueforge-org/baseimage-kasmvnc:debianbookworm

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# title
ENV TITLE=Series-Troxie

USER apps
COPY --chmod=0755 . /
COPY ./root /

RUN \
  echo "**** install deps ****" && \
  chmod +x /usr/bin/series-troxide && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    libgtk-3-0 \
    mesa-vulkan-drivers && \
  echo "**** openbox tweaks ****" && \
  sed -i \
    's|</applications>|  <application title="Series Troxide" type="normal">\n    <maximized>yes</maximized>\n  </application>\n</applications>|' \
    /etc/xdg/openbox/rc.xml && \
  curl -o \
    /usr/share/icons/hicolor/scalable/apps/series-troxide.svg -L \
    "https://raw.githubusercontent.com/MaarifaMaarifa/series-troxide/main/assets/logos/series-troxide.svg" && \
  echo "**** cleanup ****" && \
  apt-get autoclean && \
  rm -rf \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /tmp/*

# add local files
USER apps
COPY --chmod=0755 . /
COPY ./root /

# ports and volumes
EXPOSE 3000

VOLUME /config

WORKDIR /config
