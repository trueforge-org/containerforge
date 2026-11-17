FROM ghcr.io/trueforge-org/java17:17.0.16@sha256:0df84fc88306f657974b8a0995756d27f9137e68980a49be0b711cc5838d3de2

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


# ports and volumes
EXPOSE 4040
