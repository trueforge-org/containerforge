# hadolint ignore=DL3007
FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:1e4ce94f2d255834fe7557fd2de50f2c021834c8eff14e43b84b70a768cd8348

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
