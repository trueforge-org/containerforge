# hadolint ignore=DL3007
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG PACKAGE_VERSION

USER root

# hadolint ignore=DL3008,DL3015
RUN v="${PACKAGE_VERSION#*:}" && \
    test "${v%%-*}" = "${VERSION}" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        "goaccess=${PACKAGE_VERSION}" \
    && apt-get purge -y --auto-remove \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --chmod=0755 start.sh /start.sh

ENV HOME=/config \
    GOACCESS_LOG_DIR=/opt/log

USER apps
COPY --chmod=0755 . /

EXPOSE 7880

VOLUME /config

CMD ["/start.sh"]
