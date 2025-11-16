
FROM openjdk:8-alpine AS buildstage

RUN \
  echo "**** Install build requirements ****" && \
  apk add \
    bash \
    curl \
    jq && \
  echo "**** Download Davos ****" && \
  if [ -z ${VERSION+x} ]; then \
    VERSION=$(curl -sX GET https://api.github.com/repos/linuxserver/davos/releases/latest \
    | jq -r '. | .tag_name'); \
  fi && \
  curl -o \
    /tmp/davos.tar.gz -L \
    "https://github.com/linuxserver/davos/archive/${VERSION}.tar.gz" && \
  echo "**** Build Davos For Release ****" && \
  mkdir -p \
    /app/davos/ && \
  tar xf \
    /tmp/davos.tar.gz -C \
    /app/davos/ --strip-components=1 && \
  cd /app/davos/ && \
  ./gradlew -Penv=release clean build && \
  echo "**** Copy Finished Jar ****" && \
  cp build/libs/*.jar /davos.jar && \
  chmod 755 /davos.jar

FROM ghcr.io/trueforge-org/ubuntu:24.4

# set version label
ARG VERSION

# install packages
RUN \
  apk add --no-cache \
    nss \
    openjdk8-jre \
    sqlite-libs && \

# copy files from build stage and local files
COPY --from=buildstage /davos.jar /app/davos/davos.jar
COPY root/ /

# ports and volumes
EXPOSE 8080
WORKDIR /app/davos
VOLUME /config
