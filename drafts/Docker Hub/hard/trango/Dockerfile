# Web build: React frontend. Upstream is dormant and uses a Node 12-era toolchain.
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5 AS web

ARG VERSION
USER root
WORKDIR /src

ENV npm_config_cache=/tmp/npm \
    NODE_OPTIONS=--openssl-legacy-provider

# UNVERIFIED: the legacy OpenSSL flag is needed for webpack 4 on Node 17+. Remove it if the build passes without it.
# VERSION is the upstream git commit (no releases or tags exist).
RUN set -eux; \
    curl -fsSL "https://github.com/trango-io/trango-self-hosted/archive/${VERSION}.tar.gz" \
        | tar xz --strip-components=1 -C /src; \
    cd /src/app; \
    npm ci --legacy-peer-deps; \
    npm run build; \
    # UNVERIFIED: api.py binds 0.0.0.0:8081 in upstream. Bind to loopback only. If the string does not match, the API stays on 0.0.0.0.
    sed -i "s/host='0.0.0.0'/host='127.0.0.1'/" api.py; \
    mkdir -p /out/www /out/api; \
    cp -a /src/app/build/. /out/www/; \
    cp /src/app/api.py /out/api/api.py; \
    cp /src/LICENSE /out/LICENSE; \
    rm -rf /tmp/npm

# C++ discovery server (WebSocketWS). Built from the same upstream commit.
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS ws

ARG VERSION
USER root
WORKDIR /src

# UNVERIFIED: modern boost and g++ may need -std=c++17 or -DBOOST_BIND_GLOBAL_PLACEHOLDERS.
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        g++ \
        libboost-system-dev \
        libssl-dev; \
    curl -fsSL "https://github.com/trango-io/trango-self-hosted/archive/${VERSION}.tar.gz" \
        | tar xz --strip-components=1 -C /src; \
    cd /src/discoveryserver/src; \
    mkdir -p /out; \
    g++ main.cpp WebSocketMainWS.cpp WebSocketWS.cpp \
        -I ../lib/SimpleWebSocketServer/ \
        -lboost_system -lssl -lcrypto -lpthread \
        -o /out/WebSocketWS; \
    # UNVERIFIED: config.ini location. The binary reads it from its working directory.
    cp config.ini /out/config.ini; \
    rm -rf /var/lib/apt/lists/*

# Final stage
FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

ARG VERSION
USER root

# UNVERIFIED package names for 26.04 (boost version, libssl). Check with ldd /app/bin/WebSocketWS.
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        libboost-system1.90.0 \
        libssl3t64 \
        nginx \
        openssl; \
    rm -rf /var/lib/apt/lists/* /tmp/*

# Flask API for /checkurl. UNVERIFIED: flask-restful compatibility with current Flask. Pin versions after testing.
RUN /app/venv/bin/pip install --no-cache-dir flask flask-restful flask-cors

COPY --from=web /out/www /app/www
COPY --from=web /out/api /app/api
COPY --from=web /out/LICENSE /usr/share/licenses/trango/LICENSE
COPY --from=ws /out/WebSocketWS /app/bin/WebSocketWS
COPY --from=ws /out/config.ini /app/bin/config.ini

# Only /config is writable. Nginx, the API and the discovery server run from /tmp/trango.
ENV HOME=/config

USER apps
COPY --chmod=0755 . /

EXPOSE 8080 8443
VOLUME /config
WORKDIR /config

CMD ["/start.sh"]
