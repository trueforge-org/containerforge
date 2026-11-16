
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:6694765a55a999799d0b37f806a0e0ba11ceb4dcb22392b63f1b74b4123ea175

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
  echo "**** install packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    ngircd && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/*

# copy local files
USER apps
COPY --chmod=0755 . /


# ports and volumes
EXPOSE 6667

VOLUME /config

WORKDIR /config
