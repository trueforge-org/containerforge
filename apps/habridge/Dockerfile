FROM ghcr.io/trueforge-org/java8:8@sha256:9365e4b5b189d386ef884c2d34bf0be144a02429beef8d0d0e17eceb475c2d16

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# install packages
RUN \
    echo "**** install runtime packages ****" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        libcap2 \
        libnss3 \
        libsqlite3-0 && \
    rm -rf /var/lib/apt/lists/* && \
    echo "**** install ha-bridge ****" && \
    mkdir -p \
        /app && \
    curl -o \
        /app/ha-bridge.jar -L \
        "https://github.com/bwssytems/ha-bridge/releases/download/v${VERSION}/ha-bridge-${VERSION#v}.jar"

# copy local files
USER apps
COPY --chmod=0755 . /


# ports and volumes
EXPOSE 8080
VOLUME /config

WORKDIR /config
