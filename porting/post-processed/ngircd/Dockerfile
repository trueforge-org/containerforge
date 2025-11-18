
FROM ghcr.io/trueforge-org/ubuntu:24.4@sha256:a4b6def0d259d9473207e9633dc5c1849f8b3c7ebc38f0a2bfd666a8b92151ed

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
  echo "**** install packages ****" && \
  apk add --no-cache \
    ngircd==${VERSION} \
    ngircd-doc==${VERSION} && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/*

# copy local files
USER apps
COPY . /
COPY ./root /

# ports and volumes
EXPOSE 6667

VOLUME /config
