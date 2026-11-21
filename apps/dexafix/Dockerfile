FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:1e4ce94f2d255834fe7557fd2de50f2c021834c8eff14e43b84b70a768cd8348

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN mkdir -p /app && \
    echo "**** install DexaFix ****" && \
    curl -o \
        /tmp/dexafix.tar.gz -L \
        "https://github.com/trueforge-org/dexafix/releases/download/v${VERSION}/dexafix_${VERSION}_linux_${TARGETARCH}.tar.gz" && \
    tar -xzf \
        /tmp/dexafix.tar.gz -C \
        /app && \
    chown -R apps:apps /app && \
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
