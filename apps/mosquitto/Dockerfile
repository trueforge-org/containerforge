# hadolint ignore=DL3007
FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:a3ec289cfc10acc23a20cfb4fe5033c944ce3073dc4a53157c093ffb52f983b1

ARG VERSION
ARG PACKAGE_VERSION

USER root

# hadolint ignore=DL3008,DL3015
RUN test "${PACKAGE_VERSION%%-*}" = "${VERSION}" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        "mosquitto=${PACKAGE_VERSION}" \
    && apt-get purge -y --auto-remove \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    mkdir -p /mosquitto/config /mosquitto/configinc /mosquitto/data && \
    chown -R apps:apps /mosquitto

USER apps
COPY --chmod=0755 . /

EXPOSE 1883

WORKDIR /mosquitto
VOLUME /mosquitto/data
