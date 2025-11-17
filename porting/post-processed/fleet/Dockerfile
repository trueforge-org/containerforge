
FROM ghcr.io/trueforge-org/ubuntu:24.4

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# default env
ENV fleet_database_driver="org.mariadb.jdbc.Driver" \
fleet_app_port=8080

RUN \
  echo "**** install runtime packages ****" && \
  apk -U --no-cache add \
    openjdk11-jre-headless && \
  echo "**** install fleet ****" && \
  mkdir -p \
    /app/fleet && \
  curl -o \
    /app/fleet/fleet.jar -L \
    "https://github.com/linuxserver/fleet/releases/download/${VERSION}/fleet-${VERSION}.jar" && \
  echo "**** clean up ****" && \
  rm -rf \
    /tmp/*

# copy files
USER apps
COPY . /


# ports and volumes
EXPOSE 8080
WORKDIR /app/fleet
