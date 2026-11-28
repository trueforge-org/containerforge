# Closed-source vendor payload, no licence published (see plan.md "Fix attempt").
# The payload is a Go binary linked against musl (built on Alpine 3.10), so the musl loader is installed
# on the ubuntu base. The vendor image also ships chromium and a Microsoft font, which are NOT copied.
FROM docker.io/crazyq/pt_helper@sha256:43a4f8707b2c95a767185fabdeb5005aac1109af62fbad74249e24471ba976a8 AS vendor

# hadolint ignore=DL3007
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION

USER root

# hadolint ignore=DL3008
RUN apt-get update && \
    apt-get install -y --no-install-recommends musl && \
    ln -s /config /data && \
    apt-get purge -y --auto-remove && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --from=vendor /bin/pt_helper /app/pt_helper
COPY --from=vendor /bin/template /app/template
COPY --from=vendor /bin/public /app/public
COPY --from=vendor /bin/config /app/config
COPY --from=vendor /bin/pt_helper.db /app/pt_helper.db

# The version is the one in the shipped config.toml.
RUN grep -q "^version = \"${VERSION}\"" /app/config/config.toml && \
    chown -R root:root /app && \
    chmod -R a+rX /app

ENV HOME=/config

USER apps
COPY --chmod=0755 . /

WORKDIR /app
VOLUME ["/config"]

EXPOSE 8192

CMD ["/start.sh"]
