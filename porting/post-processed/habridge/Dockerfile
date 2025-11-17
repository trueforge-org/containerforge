FROM ghcr.io/trueforge-org/ubuntu:24.4

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# install packages
RUN \
  echo "**** install runtime packages ****" && \
  apk add --no-cache \
    libcap \
    nss \
    openjdk8-jre \
    sqlite-libs && \
  echo "**** install ha-bridge ****" && \
  mkdir -p \
    /app && \
  curl -o \
    /app/ha-bridge.jar -L \
    "https://github.com/bwssytems/ha-bridge/releases/download/v${VERSION}/ha-bridge-${VERSION:1}.jar" && \
# copy local files
USER apps
COPY . /
COPY ./root /

# ports and volumes
EXPOSE 8080
VOLUME /config
