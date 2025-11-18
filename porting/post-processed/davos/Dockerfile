
FROM ghcr.io/trueforge-org/java8:rolling AS buildstage

RUN \
  echo "**** Install build requirements ****" && \
  echo "**** Download Davos ****" && \
  curl -o /tmp/davos.tar.gz -L "https://github.com/linuxserver/davos/archive/${VERSION}.tar.gz" && \
  echo "**** Build Davos For Release ****" && \
  mkdir -p /app/davos/ && \
  tar xf /tmp/davos.tar.gz -C /app/davos/ --strip-components=1 && \
  cd /app/davos/ && \
  ./gradlew -Penv=release clean build && \
  echo "**** Copy Finished Jar ****" && \
  cp build/libs/*.jar /davos.jar && \
  chmod 755 /davos.jar

FROM ghcr.io/trueforge-org/java8:rolling

# set version label
ARG VERSION
ARG TARGETARCH
USER root

## TODO test with JAVA17 otherwise make another base
RUN \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    openjdk-8-jre-headless \
    libsqlite3-0 && \
  rm -rf /var/lib/apt/lists/*


# ports and volumes
EXPOSE 8080
WORKDIR /app/davos
VOLUME /config
