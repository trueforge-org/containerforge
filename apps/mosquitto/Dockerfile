# hadolint ignore=DL3007
FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

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
