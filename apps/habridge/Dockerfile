FROM ghcr.io/trueforge-org/java8:8@sha256:2b8122319f49101e163e0f670bf9924a83cd27a65b056f459a8f04a5e6461e69

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
