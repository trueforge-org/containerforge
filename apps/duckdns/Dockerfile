
FROM ghcr.io/trueforge-org/ubuntu:24.4@sha256:c5a3b56e4d22600d2b618d602d487732516cc067cb21969798210c3b12304842

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
COPY --chmod=0755 . /


WORKDIR /config
VOLUME /config
