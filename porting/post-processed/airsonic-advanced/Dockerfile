
FROM ghcr.io/trueforge-org/ubuntu:24.4

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# environment settings
ENV AIRSONIC_ADVANCED_HOME="/app" \
AIRSONIC_ADVANCED_SETTINGS="/config" \
LANG="C.UTF-8"

RUN \
  echo "**** install runtime packages ****" && \
  apk add --no-cache \
    ffmpeg \
    flac \
    fontconfig \
    lame \
    openjdk17-jre \
    ttf-dejavu \
    vorbis-tools && \
  echo "**** install airsonic advanced ****" && \
  mkdir -p \
    ${AIRSONIC_ADVANCED_HOME} && \
  curl -o \
  ${AIRSONIC_ADVANCED_HOME}/airsonic.war -L \
    "https://github.com/kagemomiji/airsonic-advanced/releases/download/${VERSION}/airsonic.war" && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/*

# add local files
USER apps
COPY . /


# ports and volumes
EXPOSE 4040
