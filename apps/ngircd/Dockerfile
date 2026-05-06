
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:0ddd714cd20cf10c41ba76066e9579cfc785579f1b801c3656b4bc0ceb151442

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
