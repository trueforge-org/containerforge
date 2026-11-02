FROM ghcr.io/cloudnative-pg/postgresql:15.19-standard-trixie@sha256:994fa6017fcdc88ce3f4a86bdc45ed719b78380f1e6c60f7cefea2679e63d6cc

ARG VERSION
ARG PG_MAJOR
ARG TIMESCALEDB_VERSION

USER root

# hadolint ignore=DL3008,DL3015,DL4006,SC1091
RUN set -eux; \
    postgres --version | grep -F " ${VERSION} "; \
    apt-get update; \
    apt-get install -y --no-install-recommends ca-certificates curl gnupg; \
    curl -fsSL https://packagecloud.io/timescale/timescaledb/gpgkey | gpg --dearmor -o /usr/share/keyrings/timescaledb.gpg; \
    codename="$(. /etc/os-release; echo "${VERSION_CODENAME}")"; \
    echo "deb [signed-by=/usr/share/keyrings/timescaledb.gpg] https://packagecloud.io/timescale/timescaledb/debian/ ${codename} main" \
      > /etc/apt/sources.list.d/timescaledb.list; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      "timescaledb-2-loader-postgresql-${PG_MAJOR}=${TIMESCALEDB_VERSION}~*" \
      "timescaledb-2-postgresql-${PG_MAJOR}=${TIMESCALEDB_VERSION}~*"; \
    mkdir -p /usr/share/licenses/timescaledb; \
    curl -fsSL -o /usr/share/licenses/timescaledb/LICENSE "https://raw.githubusercontent.com/timescale/timescaledb/${TIMESCALEDB_VERSION}/LICENSE"; \
    curl -fsSL -o /usr/share/licenses/timescaledb/LICENSE-APACHE "https://raw.githubusercontent.com/timescale/timescaledb/${TIMESCALEDB_VERSION}/LICENSE-APACHE"; \
    curl -fsSL -o /usr/share/licenses/timescaledb/LICENSE-TIMESCALE "https://raw.githubusercontent.com/timescale/timescaledb/${TIMESCALEDB_VERSION}/tsl/LICENSE-TIMESCALE"; \
    rm -f /etc/apt/sources.list.d/timescaledb.list /usr/share/keyrings/timescaledb.gpg; \
    apt-get purge -y --auto-remove curl gnupg; \
    mkdir -p /config; \
    chown 26:26 /config; \
    rm -rf /var/lib/apt/lists/* /var/cache/* /var/log/* /tmp/* /var/tmp/*

# CloudNativePG runs its images as UID 26, this base has no apps user
USER 26
COPY --chmod=0755 . /

EXPOSE 5432
VOLUME /config

CMD ["/start.sh"]
