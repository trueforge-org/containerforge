
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:e566b6c11ab30372ddb0ee460a2f65699fd50ad2eb148ddac0d7800074159f19

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
