# syntax=docker/dockerfile:1
# Upstream: https://github.com/lancachenet/monolithic (config overlay on lancachenet/ubuntu-nginx)
# Base nginx module availability (slice, stream, stream_ssl_preread, realip) is UNVERIFIED: check `nginx -V`.

FROM ghcr.io/trueforge-org/nginx:1.28.3@sha256:3a862278083a33d9ff969e987ee3a6ab24d2b928c35df07b2e69fa6f5d4e6cc1

# Upstream lancachenet/monolithic commit this overlay is ported from (VERSION in docker-bake.hcl)
ARG VERSION
# uklans/cache-domains ref (CACHE_DOMAINS_REF in docker-bake.hcl)
ARG CACHE_DOMAINS_REF

# Only the variables start.sh reads so far. Other upstream variables wait for their port.
ENV CACHE_INDEX_SIZE=500m \
    CACHE_DISK_SIZE=1000g \
    CACHE_MAX_AGE=3560d \
    NGINX_WORKER_PROCESSES=auto

USER root

# jq and git are used by the cache-domains fetch and map generation.
# UNVERIFIED: check whether the base already ships ca-certificates / git / jq and drop them if so.
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        jq \
        git \
        ca-certificates \
        libcap2-bin; \
    rm -rf /var/lib/apt/lists/*

# Fetch the cache-domains lists at a pinned ref into /app (read-only at runtime).
# The ref is a branch name until a commit SHA is verified and pinned in docker-bake.hcl.
RUN set -eux; \
    mkdir -p /app/cachedomains; \
    cd /app/cachedomains; \
    git init -q .; \
    git remote add origin "https://github.com/uklans/cache-domains.git"; \
    git fetch -q --depth=1 origin "${CACHE_DOMAINS_REF}"; \
    git checkout -q FETCH_HEAD; \
    rm -rf .git; \
    chmod -R a+rX /app/cachedomains

# Licenses: repo MIT (upstream lancachenet/monolithic), cache-domains MIT (uklans).
# UNVERIFIED: LICENSE file names inside the cache-domains checkout.
RUN set -eux; \
    mkdir -p /usr/share/licenses/lancache-monolithic; \
    cp /app/cachedomains/LICENSE /usr/share/licenses/lancache-monolithic/cache-domains-LICENSE || true; \
    printf '%s\n' "MIT License - lancachenet/monolithic, copyright 2019 LanCache.Net contributors. See https://github.com/lancachenet/monolithic" \
        > /usr/share/licenses/lancache-monolithic/LICENSE

# Allow nginx to bind 80/443 as the unprivileged apps user (UNVERIFIED: needs libcap tools present, and no NO_NEW_PRIVS)
RUN set -eux; \
    setcap 'cap_net_bind_service=+ep' "$(command -v nginx)"

# Writable scratch for nginx (rendered config, pid, temp paths) lives in /tmp
RUN set -eux; \
    mkdir -p /data/cache /data/logs; \
    chown -R apps:apps /data

# UNVERIFIED: 443 (SNI passthrough) and 8080 (metrics) are upstream ports, not yet served by this draft.
EXPOSE 80

STOPSIGNAL SIGQUIT

USER apps
COPY --chmod=0755 . /

VOLUME ["/data/cache", "/data/logs"]

HEALTHCHECK --interval=1m --timeout=5s --start-period=120s --retries=3 \
    CMD curl --fail http://127.0.0.1/lancache-heartbeat || exit 1

CMD ["/start.sh"]
