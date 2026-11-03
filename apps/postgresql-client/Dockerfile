# hadolint ignore=DL3007
FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:a3ec289cfc10acc23a20cfb4fe5033c944ce3073dc4a53157c093ffb52f983b1

ARG TARGETPLATFORM
ARG VERSION
ARG PACKAGE_VERSION
ARG UMASK=022

USER root

# hadolint ignore=DL3008,DL3015,SC2086,SC2155
RUN test "${PACKAGE_VERSION%%-*}" = "${VERSION}" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        "postgresql-client-${VERSION%%.*}=${PACKAGE_VERSION}" \
    && case "${TARGETPLATFORM}" in \
         'linux/amd64') export ARCH='linux-x64' ;; \
       esac \
    && apt-get purge -y --auto-remove \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && mkdir -p /app \
    && chmod -R u=rwX,go=rX /app \
    && printf "umask %d\n" "${UMASK}" >> /etc/profile

USER apps
COPY --chmod=0755 . /







