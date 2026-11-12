
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f5810a8898e3c4010e9609799c2cc0ef871d42a7637fbdd77f2c62c1e67b495c

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
