FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# /secrets/<name> are the mount points of the volumes `secrets init` fills (deploy/): a new named
# volume copies the owner of its mount point, so the processes can read what init puts there.
RUN mkdir -p /app /secrets/api /secrets/web /secrets/worker /secrets/body \
        /secrets/db /secrets/dbsetup /secrets/valkey && \
    echo "**** install DexaFix ****" && \
    curl -o \
        /tmp/dexafix.tar.gz -L \
        "https://github.com/trueforge-org/dexafix/releases/download/v${VERSION}/dexafix_${VERSION}_linux_${TARGETARCH}.tar.gz" && \
    tar -xzf \
        /tmp/dexafix.tar.gz -C \
        /app && \
    chown -R apps:apps /app /secrets && \
    echo "**** cleanup ****" && \
    rm -rf \
        /tmp/*

COPY --chmod=0755 . /
USER apps
WORKDIR /config
VOLUME /config

ENV DEXAFIX_LISTEN=:8080 \
    DEXAFIX_INTERNAL_LISTEN=:8081 \
    DEXAFIX_DSN=file:/config/dexafix.db \
    DEXAFIX_ENCRYPTION_KEY_FILE=/config/dexafix.key

# 8080 is plain HTTP. HTTPS (and HTTP/3 on UDP) listen on the port set on the Admin page, 8443 by
# default, once a certificate is configured; publish it with -p 8443:8443 -p 8443:8443/udp.
#
# Separate processes instead of one: run the image with `serve api` (the database; public API on 8080
# and the internal API on 8081), with `serve web` (the pages and the public listeners, no database)
# and with `serve worker` (talks to Withings and Strength Level for the api, no database). The
# readings, scans and estimates can run as `serve body` too (8082), with a database of its own.
# 8081 is the internal API and 8082 the body service: never publish them, keep them on a private
# network. 8081 is only used by `serve api`, 8082 only by `serve body`, see
# docs/15-split-deployment.md, docs/16-workers.md and docs/17-body-service.md.
EXPOSE 8080 8081 8082 8443 8443/udp
CMD ["serve"]
