FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

# set version label
ARG VERSION
USER root

RUN \
  echo "**** install runtime packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    dotnet-runtime-10.0=10.0.14-0ubuntu1~26.04.1 && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    $HOME/.cache && \
  rm -rf /var/lib/apt/lists/*

# The server is downloaded into /config at first start (read-only /app rule), so nothing is fetched here.
# UNVERIFIED: a vendor license file in the server tarball is not confirmed; the EULA reference goes in the PR.

# copy local files
USER apps
COPY --chmod=0755 . /

ENV VS_CHANNEL=stable \
    STATIC_V=""

# ports and volumes
EXPOSE 42420
VOLUME /config

WORKDIR /config
