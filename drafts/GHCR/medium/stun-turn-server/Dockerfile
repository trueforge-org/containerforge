# hadolint ignore=DL3007
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION
ARG PACKAGE_VERSION

ENV TURN_PORT=3478 \
    TURN_TLS_PORT=5349 \
    TURN_LISTEN_IP=0.0.0.0 \
    TURN_REALM=example.com

USER root

# openssl is needed by start.sh to create a self-signed certificate. UNVERIFIED that the base lacks it; check and drop if present.
# hadolint ignore=DL3008,DL3015
RUN test "${PACKAGE_VERSION%%-*}" = "${VERSION}" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        "coturn=${PACKAGE_VERSION}" \
        openssl \
    && mkdir -p /usr/share/licenses/stun-turn-server \
    && cp /usr/share/doc/coturn/copyright /usr/share/licenses/stun-turn-server/LICENSE \
    && apt-get purge -y --auto-remove \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

USER apps
COPY --chmod=0755 . /

EXPOSE 3478/tcp 3478/udp 5349/tcp

VOLUME /config

CMD ["/start.sh"]
