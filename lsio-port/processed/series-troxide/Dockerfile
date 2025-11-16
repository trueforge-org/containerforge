# buildstage
FROM ghcr.io/linuxserver/baseimage-debian:bookworm as buildstage

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
FROM ghcr.io/linuxserver/baseimage-kasmvnc:debianbookworm

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"

# title
ENV TITLE=Series-Troxie

COPY --from=buildstage /root/.cargo/bin/series-troxide /usr/bin/series-troxide

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
COPY /root /

# ports and volumes
EXPOSE 3000

VOLUME /config
