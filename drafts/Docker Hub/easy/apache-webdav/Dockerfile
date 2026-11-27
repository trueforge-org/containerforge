# hadolint ignore=DL3007
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG PACKAGE_VERSION

USER root

# Pinned Ubuntu package, guarded against VERSION like apps/valkey.
# UNVERIFIED: apache2 starts with -f and the modules listed in the template, with no envvars file.
# hadolint ignore=DL3008,DL3015
RUN test "${PACKAGE_VERSION%%-*}" = "${VERSION}" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        "apache2=${PACKAGE_VERSION}" \
    && apt-get purge -y --auto-remove \
    && mkdir -p /usr/share/licenses/apache-webdav \
    && cp /usr/share/doc/apache2/copyright /usr/share/licenses/apache-webdav/copyright \
    && test -f /usr/lib/apache2/modules/mod_dav_fs.so \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Shared data directory, owned by the runtime user
RUN install -d -o 568 -g 568 /data

USER apps
COPY --chmod=0755 . /

WORKDIR /config
EXPOSE 8080
VOLUME /config
VOLUME /data
