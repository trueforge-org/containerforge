
FROM ghcr.io/trueforge-org/ubuntu:24.04@sha256:8f6de6a5c28a657e36d1b7630580eaf27788aac5d0603d18d644a1ac1332f061

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
