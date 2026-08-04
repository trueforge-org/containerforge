
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:e855efee08935623aad3a45e3e554e52216b53d07105a9b3beb585ea1e78352c

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
