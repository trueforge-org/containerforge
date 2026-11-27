FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION
ARG PACKAGE_VERSION

USER root

# Check the package is Kodi ${VERSION} (strip the epoch and the +dfsg suffix), then install it pinned.
# UNVERIFIED: kodi-bin and kodi-data exact versions on 26.04 (only kodi-eventclients-common 2:21.3+dfsg-1ubuntu1 was checked)
# hadolint ignore=DL3008,DL3015
RUN V="${PACKAGE_VERSION#*:}" \
    && test "${V%%+*}" = "${VERSION}" \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        "kodi-bin=${PACKAGE_VERSION}" \
        "kodi-data=${PACKAGE_VERSION}" \
        xvfb \
        libgl1-mesa-dri \
    && mkdir -p /usr/share/licenses/kodi-headless \
    && cp /usr/share/doc/kodi-bin/copyright /usr/share/licenses/kodi-headless/copyright \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV HOME=/config \
    XDG_RUNTIME_DIR=/tmp/runtime \
    XDG_CACHE_HOME=/tmp/cache \
    DISPLAY=:99

COPY --chmod=0755 . /

USER apps

# 8080 web UI, 9090 websocket, 9777/udp event server
EXPOSE 8080 9090 9777/udp
VOLUME /config

CMD ["/start.sh"]
