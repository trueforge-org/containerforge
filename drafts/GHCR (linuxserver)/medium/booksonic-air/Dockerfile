FROM ghcr.io/trueforge-org/java17:17.0.16@sha256:efdc903d9ce0436b6207bc5a4e732d24a27231851975c999770fd8709a8316b8

# set version label
ARG VERSION
USER root

# environment settings
# UNVERIFIED: booksonic.war runs on Java 17 (linuxserver ships openjdk11). Fall back to java11 if not.
ENV BOOKSONIC_AIR_HOME="/app/booksonic-air" \
    BOOKSONIC_AIR_SETTINGS="/config" \
    LANG="C.UTF-8"

RUN \
  echo "**** install runtime packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    ffmpeg \
    flac \
    fontconfig \
    lame \
    fonts-dejavu-core && \
  echo "**** install booksonic air ****" && \
  mkdir -p "${BOOKSONIC_AIR_HOME}" && \
  curl -fL -o "${BOOKSONIC_AIR_HOME}/booksonic.war" \
    "https://github.com/popeen/Booksonic-Air/releases/download/v${VERSION}/booksonic.war" && \
  echo "**** install license ****" && \
  mkdir -p /usr/share/licenses/booksonic-air && \
  curl -fL -o /usr/share/licenses/booksonic-air/LICENSE \
    "https://raw.githubusercontent.com/popeen/Booksonic-Air/v${VERSION}/LICENSE" && \
  echo "**** cleanup ****" && \
  apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/*

# add local files
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 4040
VOLUME /config

USER apps
