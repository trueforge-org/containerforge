
FROM ghcr.io/trueforge-org/java17:17.0.16@sha256:74b81362a2cf4b7f6efb8eb67baf0d1090ce56b38fc9e7a0dc11333b35179e1a

# set version label
# The JAR is not versioned. VERSION is the wrapper tag used for tracking only.
ARG VERSION
USER root

# environment variables.
ENV HOME=/config

# UNVERIFIED: no checksum is published for the JAR. The image changes whenever the vendor changes the file.
# UNVERIFIED: headless operation. The desktop/VNC stack of the upstream GUI image is not included in this draft.
RUN \
  echo "**** download jdownloader ****" && \
  mkdir -p \
    /app/jdownloader && \
  curl -fsSL -o \
    /app/jdownloader/JDownloader.jar \
    "https://installer.jdownloader.org/JDownloader.jar" && \
  echo "**** set permissions ****" && \
  chown -R root:root \
    /app/jdownloader && \
  chmod -R a+rX \
    /app/jdownloader && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/*

# copy files
USER apps
COPY --chmod=0755 . /


# ports and volumes
# UNVERIFIED: the upstream image exposes 3129 for MyJDownloader direct connection. Confirm before relying on it.
EXPOSE 3129
VOLUME /config
WORKDIR /config
ENTRYPOINT ["/start.sh"]
