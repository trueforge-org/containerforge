# hadolint ignore=DL3007
FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:bc182517d87eb71b9a71e11941223716611ebe6002864b1a28d03cca78fa5a35

ARG VERSION
ARG PACKAGE_VERSION

USER root

# hadolint ignore=DL3008,DL3015
RUN apt-get update && \
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
