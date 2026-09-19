
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:5491a2f46a8408f4085d5b92ff59358bafd56e7f26058b30347bfdefa568ed8a

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
