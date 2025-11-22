## TODO: set version tag
FROM ghcr.io/trueforge-org/java17:rolling@sha256:f8fb9c219b55e0be665dc919e09c7997f21252db6b1814b755525c94c727433e

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
    fonts-dejavu-core \
    vorbis-tools && \
  echo "**** install airsonic advanced ****" && \
  mkdir -p \
    ${AIRSONIC_ADVANCED_HOME} && \
  mkdir -p "/run/tomcat.4040" && \
  chown -R 568:568 /run/tomcat.4040 && \
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
