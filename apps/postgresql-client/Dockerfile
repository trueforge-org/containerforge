# hadolint ignore=DL3007
FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:1685c0f458568fddff62e0fe0f0804de9d13469bd9fc967bc8c7bde606166969

ARG TARGETPLATFORM
ARG VERSION
ARG UMASK=022

USER root

# hadolint ignore=DL3008,DL3015,SC2086,SC2155
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        postgresql-client \
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







