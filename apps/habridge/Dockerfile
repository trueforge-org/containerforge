FROM ghcr.io/trueforge-org/ubuntu:24.4

# set version label
ARG VERSION

# install packages
RUN \
  echo "**** install runtime packages ****" && \
  apk add --no-cache \
    libcap \
    nss \
    openjdk8-jre \
    sqlite-libs && \
  echo "**** install ha-bridge ****" && \
  if [ -z ${VERSION+x} ]; then \
    VERSION=$(curl -sL "https://api.github.com/repos/bwssytems/ha-bridge/releases/latest" \
    | jq -r '.tag_name'); \
  fi && \
  mkdir -p \
    /app && \
  curl -o \
    /app/ha-bridge.jar -L \
    "https://github.com/bwssytems/ha-bridge/releases/download/v${VERSION}/ha-bridge-${VERSION:1}.jar" && \

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 8080
VOLUME /config
