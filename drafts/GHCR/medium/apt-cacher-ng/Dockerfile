# hadolint ignore=DL3007
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG PACKAGE_VERSION

USER root

# The package is pinned to the Ubuntu 26.04 build, and the build fails if VERSION and PACKAGE_VERSION disagree (valkey pattern).
# UNVERIFIED: the exact PACKAGE_VERSION string in the resolute archive, and the acng.conf key names used by sed below.
# hadolint ignore=DL3008,DL3015
RUN test "${PACKAGE_VERSION%%-*}" = "${VERSION}" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        "apt-cacher-ng=${PACKAGE_VERSION}" \
    && sed -i \
        -e 's|^ForeGround:.*|ForeGround: 1|' \
        -e 's|^CacheDir:.*|CacheDir: /config/cache|' \
        -e 's|^LogDir:.*|LogDir: /config/log|' \
        /etc/apt-cacher-ng/acng.conf \
    && echo "PidFile: /tmp/apt-cacher-ng/pid" >> /etc/apt-cacher-ng/acng.conf \
    && mkdir -p /usr/share/licenses/apt-cacher-ng \
    && cp /usr/share/doc/apt-cacher-ng/copyright /usr/share/licenses/apt-cacher-ng/LICENSE \
    && apt-get purge -y --auto-remove \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# PassThroughPattern (upstream sets `.* #`, which allows CONNECT to any host) is left at the package default.
# UNVERIFIED: deciding whether to widen it is a PR decision. See the plan's section 10.

USER apps
COPY --chmod=0755 . /

EXPOSE 3142

VOLUME ["/config"]

CMD ["/start.sh"]
