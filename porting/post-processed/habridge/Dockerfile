## TODO: check if java17 works, otherwise make java 8 base
FROM ghcr.io/trueforge-org/java17:17.0.16@sha256:030eb2ac2a66c79c34ed1467851dd5599d06dc4fa5777e100b8e4c980ff54193

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
