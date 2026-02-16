FROM ghcr.io/trueforge-org/java8:8 AS buildstage
USER root
ARG VERSION
ARG TARGETARCH

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

FROM ghcr.io/trueforge-org/java8:8

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    libsqlite3-0 && \
  chown -R apps:apps /app && chmod -R 755 /app && \
  rm -rf /var/lib/apt/lists/*

USER apps
COPY --from=buildstage /davos.jar /app/davos.jar
COPY . /

# ports and volumes
EXPOSE 8080
VOLUME /download

WORKDIR /config
VOLUME /config
