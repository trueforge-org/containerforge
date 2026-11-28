# Cryptominer image: policy review of this app is still open, see plan.md section 10.
# hadolint ignore=DL3007
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG PACKAGE_VERSION

USER root

# hadolint ignore=DL3008,DL3015
RUN test "${PACKAGE_VERSION%%+*}" = "${VERSION}" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        "xmrig=${PACKAGE_VERSION}" \
    && mkdir -p /usr/share/licenses/xmrig \
    && cp /usr/share/doc/xmrig/copyright /usr/share/licenses/xmrig/copyright \
    && apt-get purge -y --auto-remove \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --chmod=0755 start.sh /start.sh

ENV HOME=/config

USER apps
COPY --chmod=0755 . /

WORKDIR /config
VOLUME ["/config"]

EXPOSE 8080

CMD ["/start.sh"]
