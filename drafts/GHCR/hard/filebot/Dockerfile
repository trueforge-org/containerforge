
FROM ghcr.io/trueforge-org/java17:17.0.16@sha256:74b81362a2cf4b7f6efb8eb67baf0d1090ce56b38fc9e7a0dc11333b35179e1a

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# environment variables.
# Java scratch goes to /tmp, and FileBot state goes to /config.
ENV HOME=/config \
  JAVA_TOOL_OPTIONS=-Djava.io.tmpdir=/tmp

RUN \
  echo "**** install packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    xz-utils \
    libmediainfo0v5 \
    libchromaprint-tools && \
  echo "**** download and verify filebot ****" && \
  mkdir -p \
    /tmp/filebot \
    /app/filebot && \
  curl -fsSL -o \
    "/tmp/filebot/FileBot_${VERSION}-portable.tar.xz" \
    "https://get.filebot.net/filebot/FileBot_${VERSION}/FileBot_${VERSION}-portable.tar.xz" && \
  curl -fsSL -o \
    "/tmp/filebot/FileBot_${VERSION}-portable.tar.xz.sha256" \
    "https://get.filebot.net/filebot/FileBot_${VERSION}/FileBot_${VERSION}-portable.tar.xz.sha256" && \
  # UNVERIFIED: the .sha256 file name and content must be checked at build time.
  (cd /tmp/filebot && sha256sum -c "FileBot_${VERSION}-portable.tar.xz.sha256") && \
  echo "**** extract filebot ****" && \
  # UNVERIFIED: archive layout. Check with tar -tJf before relying on --strip-components=1.
  tar -xJf \
    "/tmp/filebot/FileBot_${VERSION}-portable.tar.xz" \
    -C /app/filebot \
    --strip-components=1 && \
  echo "**** license ****" && \
  mkdir -p \
    /usr/share/licenses/filebot && \
  printf '%s\n' \
    "FileBot (https://www.filebot.net/) portable build ${VERSION}." \
    "UNVERIFIED: the FileBot license and any key requirement were not confirmed. Copy the upstream license file here if the archive has one." \
    "The jlesage/docker-filebot wrapper is MIT licensed (https://github.com/jlesage/docker-filebot)." \
    > /usr/share/licenses/filebot/NOTICE && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/filebot \
    /var/lib/apt/lists/*

RUN \
  echo "**** set permissions ****" && \
  chown -R root:root \
    /app/filebot && \
  chmod -R a+rX \
    /app/filebot

# copy files
USER apps
COPY --chmod=0755 . /


# volumes
VOLUME /config
WORKDIR /config
ENTRYPOINT ["/start.sh"]
