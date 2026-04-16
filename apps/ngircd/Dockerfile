
FROM ghcr.io/trueforge-org/ubuntu:24.04@sha256:b91efc25164fbe723a41eca66f239d8f6c008fd7d10ceda9d5ba0975104d0432

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
