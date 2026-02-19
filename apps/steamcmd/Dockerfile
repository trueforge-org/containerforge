FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:3209530ed3169bb7c62c9010745abf292a4bcbe5b8757787aebcce488c09d520

ARG VERSION
ARG VENDOR
ARG STEAMCMD_VERSION

USER root

RUN dpkg --add-architecture i386 && \
    add-apt-repository multiverse && \
    apt-get update && \
    echo steamcmd steam/question select "I AGREE" | debconf-set-selections && \
    echo steamcmd steam/license note '' | debconf-set-selections && \
    apt-get install -y --no-install-recommends steamcmd:i386=${STEAMCMD_VERSION} && \
    ln -sf /usr/games/steamcmd /usr/local/bin/steamcmd && \
    rm -rf /var/lib/apt/lists/*

USER apps
COPY container-test.yaml /container-test.yaml
