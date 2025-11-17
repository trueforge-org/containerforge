## TODO: set version tag
FROM ghcr.io/trueforge-org/java17:rolling

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
  apt-get update && \
  apt-get install -y --no-install-recommends \
    ffmpeg \
    flac \
    fontconfig \
    lame \
    openjdk-17-jre-headless \
    fonts-dejavu-core \
    vorbis-tools && \
  echo "**** install airsonic advanced ****" && \
  mkdir -p \
    ${AIRSONIC_ADVANCED_HOME} && \
  curl -o \
  ${AIRSONIC_ADVANCED_HOME}/airsonic.war -L \
    "https://github.com/kagemomiji/airsonic-advanced/releases/download/${VERSION}/airsonic.war" && \
  echo "**** cleanup ****" && \
  apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/*

# add local files
USER apps
COPY . /


# ports and volumes
EXPOSE 4040
