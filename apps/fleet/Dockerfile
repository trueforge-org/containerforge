
FROM ghcr.io/trueforge-org/ubuntu:24.4

# set version label
ARG VERSION

# default env
ENV fleet_database_driver="org.mariadb.jdbc.Driver" \
fleet_app_port=8080

RUN \
  echo "**** install runtime packages ****" && \
  apk -U --no-cache add \
    openjdk11-jre-headless && \
  echo "**** install fleet ****" && \
  if [ -z ${VERSION+x} ]; then \
    VERSION=$(curl -sX GET "https://api.github.com/repos/linuxserver/fleet/releases/latest" \
    | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  fi && \
  mkdir -p \
    /app/fleet && \
  curl -o \
    /app/fleet/fleet.jar -L \
    "https://github.com/linuxserver/fleet/releases/download/${VERSION}/fleet-${VERSION}.jar" && \
  echo "**** clean up ****" && \
  rm -rf \
    /tmp/*

# copy files
COPY root/ /

# ports and volumes
EXPOSE 8080
WORKDIR /app/fleet
