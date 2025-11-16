
FROM ghcr.io/linuxserver/baseimage-alpine:3.22

# set version label
ARG VERSION
ARG NGIRCD_RELEASE

RUN \
  echo "**** install packages ****" && \
  if [ -z ${NGIRCD_RELEASE+x} ]; then \
    NGIRCD_RELEASE=$(curl -sL "http://dl-cdn.alpinelinux.org/alpine/v3.22/main/$TARGETARCH/APKINDEX.tar.gz" | tar -xz -C /tmp \
    && awk '/^P:ngircd$/,/V:/' /tmp/APKINDEX | sed -n 2p | sed 's/^V://'); \
  fi && \
  apk add --no-cache \
    ngircd==${NGIRCD_RELEASE} \
    ngircd-doc==${NGIRCD_RELEASE} && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/*

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 6667

VOLUME /config
