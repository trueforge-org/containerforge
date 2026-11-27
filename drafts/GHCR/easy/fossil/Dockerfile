# hadolint ignore=DL3007
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION
ARG PACKAGE_VERSION

USER root

# hadolint ignore=DL3008,DL3015
RUN upstream="${PACKAGE_VERSION#*:}" && \
    test "${upstream%%-*}" = "${VERSION}" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        "fossil=${PACKAGE_VERSION}" \
    && apt-get purge -y --auto-remove \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --chmod=0755 start.sh /start.sh

ENV HOME=/config \
    FOSSIL_PORT=8080

USER apps
COPY --chmod=0755 . /

EXPOSE 8080
VOLUME /config
CMD ["/start.sh"]
