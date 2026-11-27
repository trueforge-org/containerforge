FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

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
