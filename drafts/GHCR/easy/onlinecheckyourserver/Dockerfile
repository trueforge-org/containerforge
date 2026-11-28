FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG VENDOR

USER root

# Install only what the base lacks: check before changing this list.
# UNVERIFIED: iputils-ping needs NET_RAW at runtime when run as the apps user.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        iputils-ping \
        curl && \
    mkdir -p /config && \
    chown -R apps:apps /config && \
    rm -rf /var/lib/apt/lists/*

ENV HOME=/config \
    TMPDIR=/tmp \
    HOST=google.com \
    PING_INTERVAL=300 \
    PING_TIMEOUT=10 \
    PING_RETRY=3600 \
    PUSHOVER_APP_TOKEN="" \
    PUSHOVER_USER_TOKEN="" \
    PUSHOVER_TITLE="Online Check" \
    PUSHOVER_MESSAGE="google.com is offline!" \
    PUSHOVER_PRIORITY=0

COPY --chmod=0755 . /

USER apps

VOLUME /config
WORKDIR /config

ENTRYPOINT ["/start.sh"]
