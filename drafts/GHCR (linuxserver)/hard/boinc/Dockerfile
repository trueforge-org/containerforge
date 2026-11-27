FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

# set version label
ARG VERSION
# UNVERIFIED: apt version of boinc-client in the 26.04 archive, set in docker-bake.hcl
ARG BOINC_VERSION
ARG TARGETARCH
USER root

# headless client only: no boinc-manager, no desktop or GPU packages
RUN apt-get update && \
  apt-get install -y --no-install-recommends "boinc-client=${BOINC_VERSION}" && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV HOME=/config

USER apps
COPY --chmod=0755 . /

# UNVERIFIED: GUI RPC port of the headless client, confirm on the first build
EXPOSE 31416
VOLUME /config
WORKDIR /config
