
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:51a8cb185ca9a4d55f1ebff3d3d063ea49262babb5096ddba4a1f5432995ed01

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
