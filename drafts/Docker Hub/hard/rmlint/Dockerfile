FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG PACKAGE_VERSION

USER root

# hadolint ignore=DL3008,DL3015
RUN test "${PACKAGE_VERSION%%-*}" = "${VERSION}" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        "rmlint=${PACKAGE_VERSION}" && \
    # UNVERIFIED: copyright path of the rmlint package, confirm in the built image
    mkdir -p /usr/share/licenses/rmlint && \
    cp /usr/share/doc/rmlint/copyright /usr/share/licenses/rmlint/ && \
    apt-get purge -y --auto-remove \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV HOME=/config \
    XDG_CACHE_HOME=/tmp \
    XDG_CONFIG_HOME=/config

USER apps
COPY --chmod=0755 . /

WORKDIR /config
VOLUME /config

CMD ["/start.sh"]
