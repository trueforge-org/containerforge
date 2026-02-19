
FROM ghcr.io/trueforge-org/ubuntu:24.4@sha256:36c48bc0fd413c8ef2ae9761b1decc96fa8295f44407a9b7280bd137c2109355

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
  echo "**** install packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    dnsutils \
    logrotate && \
  rm -rf /var/lib/apt/lists/*

# add local files
USER apps
COPY container-test.yaml /container-test.yaml
COPY . /
COPY ./root /

WORKDIR /config
VOLUME /config
