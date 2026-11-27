# hadolint ignore=DL3007
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION
ARG PACKAGE_VERSION

USER root

# UNVERIFIED: Redis apt repository URL, keyring path, sources line and package names come from the plan.
# Confirm them against the official Redis install docs before merge.
# hadolint ignore=DL3008,DL3015
RUN test "${PACKAGE_VERSION%%-*}" = "${VERSION}" && \
    apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates curl gnupg && \
    curl -fsSL https://packages.redis.io/gpg | gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(. /etc/os-release && echo "$VERSION_CODENAME") main" > /etc/apt/sources.list.d/redis.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        "redis-server=${PACKAGE_VERSION}" \
        "redis-tools=${PACKAGE_VERSION}" \
    && redis-server --version | grep -q "v=${VERSION}" \
    && apt-get purge -y --auto-remove \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --chmod=0755 start.sh /start.sh

ENV REDIS_PORT=6379 \
    REDIS_DATA_DIR=/config

USER apps
COPY --chmod=0755 . /

EXPOSE 6379
VOLUME /config

CMD ["/start.sh"]
