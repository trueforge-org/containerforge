FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:a3ec289cfc10acc23a20cfb4fe5033c944ce3073dc4a53157c093ffb52f983b1

ARG TARGETARCH
ARG VERSION

USER root

# hadolint ignore=DL3008,DL3015,SC2086,DL4006
RUN set -eux; \
    case "${TARGETARCH}" in \
        amd64|arm64) ;; \
        *) echo "Unsupported architecture ${TARGETARCH}"; exit 1 ;; \
    esac; \
    apt-get update; \
    apt-get install -y --no-install-recommends ca-certificates curl; \
    base_url="https://github.com/ClickHouse/ClickHouse/releases/download/v${VERSION}-stable"; \
    for package in common-static server; do \
        file="clickhouse-${package}-${VERSION}-${TARGETARCH}.tgz"; \
        curl -fsSL -o "/tmp/${file}" "${base_url}/${file}"; \
        echo "$(curl -fsSL "${base_url}/${file}.sha512" | cut -d ' ' -f 1)  /tmp/${file}" | sha512sum -c -; \
    done; \
    tar -xzf "/tmp/clickhouse-common-static-${VERSION}-${TARGETARCH}.tgz" -C /usr/local/bin --strip-components=3 --wildcards '*/usr/bin/clickhouse'; \
    mkdir -p /etc/clickhouse-server; \
    tar -xzf "/tmp/clickhouse-server-${VERSION}-${TARGETARCH}.tgz" -C /etc/clickhouse-server --strip-components=3 --wildcards '*/etc/clickhouse-server/config.xml'; \
    ln -s /usr/local/bin/clickhouse /usr/local/bin/clickhouse-client; \
    clickhouse --version; \
    apt-get purge -y --auto-remove; \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

USER apps
COPY --chmod=0755 . /

ENV CLICKHOUSE_WATCHDOG_ENABLE=0

EXPOSE 8123 9000
VOLUME /config
WORKDIR /config
