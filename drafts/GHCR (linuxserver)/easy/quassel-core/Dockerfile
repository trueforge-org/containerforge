# hadolint ignore=DL3007
# UNVERIFIED: base digest is taken from the plan (Ubuntu 26.04)
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
# Full apt version including the epoch, for example 1:0.14.0-4ubuntu2
ARG PACKAGE_VERSION

USER root

ENV HOME=/config

# hadolint ignore=DL3008,DL3015
RUN UPSTREAM_VERSION="${PACKAGE_VERSION#*:}" && \
    test "${UPSTREAM_VERSION%%-*}" = "${VERSION}" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        "quassel-core=${PACKAGE_VERSION}" && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

USER apps
COPY --chmod=0755 . /

EXPOSE 4242/tcp

VOLUME /config

CMD ["/start.sh"]
