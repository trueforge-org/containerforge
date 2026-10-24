# hadolint ignore=DL3007
FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:fbb8b286bdadd3cda896e800061cc867ad228255b76c968de072f2bf16794598

ARG VERSION
ARG PACKAGE_VERSION

USER root

# hadolint ignore=DL3008,DL3015
RUN test "${PACKAGE_VERSION%%-*}" = "${VERSION}" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        "valkey-server=${PACKAGE_VERSION}" \
    && apt-get purge -y --auto-remove \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --chmod=0755 health /health
COPY --chmod=0755 start.sh /start.sh

ENV VALKEY_PORT=6379

USER apps
COPY --chmod=0755 . /


EXPOSE 6379

CMD ["/start.sh"]
