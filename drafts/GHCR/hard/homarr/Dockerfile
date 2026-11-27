FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

ARG VERSION
ARG TARGETARCH

# UNVERIFIED: Node major in python-node must be 24 (upstream uses node:24).
ENV \
    HOME=/config \
    NODE_ENV=production \
    DB_URL=/config/db/db.sqlite \
    DB_DIALECT=sqlite \
    DB_DRIVER=better-sqlite3 \
    AUTH_PROVIDERS=credentials \
    REDIS_IS_EXTERNAL=false

USER root

# Bundled Redis only. nginx is not installed yet: the upstream nginx template (scripts/run.sh) was not read.
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends redis-server; \
    rm -rf /var/lib/apt/lists/*

# Debian (glibc) release build. Checksums are the GitHub release digests from plan section 1.
# UNVERIFIED: top-level layout of the tarball (extracted into /app/homarr).
RUN set -eux; \
    case "${TARGETARCH}" in \
      amd64) sha256=120280ecdbd8af3fbfdeac3626a8f91f3541a0d34ccdb30bd2988f2ecad5157b ;; \
      arm64) sha256=b8e73aa11bc87bf4819c376484bfe393da901cd22623dce244a63e7a75f7d4d5 ;; \
      *) echo "unsupported architecture: ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    curl -fsSL -o /tmp/homarr.tar.gz \
      "https://github.com/homarr-labs/homarr/releases/download/v${VERSION}/build-debian-${TARGETARCH}.tar.gz"; \
    echo "${sha256}  /tmp/homarr.tar.gz" | sha256sum -c -; \
    mkdir -p /app/homarr; \
    tar -xzf /tmp/homarr.tar.gz -C /app/homarr; \
    rm -f /tmp/homarr.tar.gz

# UNVERIFIED: LICENSE file is present in the release tarball.
RUN set -eux; \
    mkdir -p /usr/share/licenses/homarr; \
    cp /app/homarr/LICENSE /usr/share/licenses/homarr/LICENSE; \
    chown -R apps:apps /app; \
    chmod -R 755 /app; \
    mkdir -p /config; \
    chown apps:apps /config

USER apps
COPY --chmod=0755 . /

EXPOSE 7575
VOLUME /config

CMD ["/start.sh"]
