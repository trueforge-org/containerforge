# hadolint ignore=DL3007
FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:e566b6c11ab30372ddb0ee460a2f65699fd50ad2eb148ddac0d7800074159f19

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

USER apps
COPY --chmod=0755 . /
