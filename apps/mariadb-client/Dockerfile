# hadolint ignore=DL3007
FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:a42a7b2fe3c044339769eca34c011337ec5ecdbb7ff3c2af30bc9105afb035b8

ARG TARGETPLATFORM
ARG VERSION
ARG UMASK=022

USER root

# hadolint ignore=DL3008,DL3015,SC2086,SC2155
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        mariadb-client \
    && case "${TARGETPLATFORM}" in \
         'linux/amd64') export ARCH='linux-x64' ;; \
       esac \
    && apt-get remove -y \
    && rm -rf /var/lib/apt/lists/* /tmp/* \
    && mkdir -p /app \
    && chmod -R u=rwX,go=rX /app \
    && printf "umask %d\n" "${UMASK}" >> /etc/profile \
    && update-ca-certificates

COPY container-test.yaml /container-test.yaml
USER apps
