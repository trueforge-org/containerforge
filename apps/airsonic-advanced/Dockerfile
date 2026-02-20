FROM ghcr.io/trueforge-org/java17:17.0.16@sha256:3a1e87c9e6ddc9b2b8b35a88209671c52ab43d8f6a2039111d04e2ca367c675c

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
COPY --chmod=0755 . /
COPY --chmod=0755 . /


# ports and volumes
EXPOSE 4040
