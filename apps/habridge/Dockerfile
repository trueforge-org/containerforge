FROM ghcr.io/trueforge-org/java8:8@sha256:1688c8c34f0a30af44013ecaadd4df04ceb466ab0a618d9322ff064c5d031c4a

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
