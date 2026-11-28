# OpenResty (nginx with Lua) built from source. Upstream uses nginxproxymanager/nginx-full:certbot-node,
# whose build is UNVERIFIED here (the base repo was not reachable).
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS openresty

ARG OPENRESTY_VERSION
ARG OPENRESTY_SHA256
USER root
WORKDIR /tmp/openresty

# UNVERIFIED: module set. Compare with the modules upstream compiles in before shipping.
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        libpcre2-dev \
        libssl-dev \
        perl \
        zlib1g-dev; \
    curl -fsSL "https://openresty.org/download/openresty-${OPENRESTY_VERSION}.tar.gz" -o openresty.tar.gz; \
    echo "${OPENRESTY_SHA256}  openresty.tar.gz" | sha256sum -c -; \
    tar xzf openresty.tar.gz --strip-components=1; \
    ./configure \
        --prefix=/usr/local/openresty \
        --conf-path=/etc/nginx/nginx.conf \
        --pid-path=/tmp/nginx/nginx.pid \
        --error-log-path=/dev/stderr \
        --http-log-path=/dev/stdout \
        --http-client-body-temp-path=/tmp/nginx/body \
        --http-proxy-temp-path=/tmp/nginx/proxy \
        --http-fastcgi-temp-path=/tmp/nginx/fastcgi \
        --http-uwsgi-temp-path=/tmp/nginx/uwsgi \
        --http-scgi-temp-path=/tmp/nginx/scgi \
        --with-http_v2_module \
        --with-http_ssl_module \
        --with-http_realip_module \
        --with-http_gzip_static_module \
        --with-http_sub_module \
        --with-http_auth_request_module \
        --with-http_stub_status_module \
        --with-stream \
        --with-stream_ssl_module \
        --with-pcre-jit; \
    make -j"$(nproc)"; \
    make install; \
    rm -rf /var/lib/apt/lists/* /tmp/openresty

# Backend and frontend build. The python-node base keeps the Node runtime the same as the final stage.
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5 AS app

ARG VERSION
USER root
WORKDIR /src

ENV YARN_CACHE_FOLDER=/tmp/yarn \
    npm_config_cache=/tmp/npm

# UNVERIFIED: yarn may need `corepack enable` on this base. The frontend build is `tsc && vite build`.
RUN set -eux; \
    curl -fsSL "https://github.com/NginxProxyManager/nginx-proxy-manager/archive/refs/tags/v${VERSION}.tar.gz" \
        | tar xz --strip-components=1 -C /src; \
    command -v yarn >/dev/null 2>&1 || corepack enable; \
    cd /src/frontend; \
    yarn install; \
    yarn build; \
    cd /src/backend; \
    yarn install --production; \
    mkdir -p /out/app /out/etc /out/var/www /out/licenses; \
    cp -a /src/backend/. /out/app/; \
    cp -a /src/frontend/dist /out/app/frontend; \
    cp -a /src/docker/rootfs/etc/nginx /out/etc/nginx; \
    cp -a /src/docker/rootfs/var/www/html /out/var/www/html; \
    cp /src/LICENSE /out/licenses/LICENSE; \
    rm -rf /tmp/yarn /tmp/npm

# Final stage
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

ARG VERSION
ARG CERTBOT_VERSION
USER root

# UNVERIFIED package names. Check each with dpkg first, since the base may already provide some.
# logrotate is left out on purpose: it needs writable state paths that the read-only rootfs does not give.
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        apache2-utils \
        jq \
        libpcre2-8-0 \
        libssl3t64 \
        openssl; \
    rm -rf /var/lib/apt/lists/* /tmp/*

COPY --from=openresty /usr/local/openresty /usr/local/openresty
RUN ln -s /usr/local/openresty/nginx/sbin/nginx /usr/local/bin/nginx

COPY --from=app /out/app /app/npm
COPY --from=app /out/etc/nginx /etc/nginx
COPY --from=app /out/var/www/html /var/www/html
COPY --from=app /out/licenses/LICENSE /usr/share/licenses/nginx-proxy-manager/LICENSE

# Patch upstream paths at build time so runtime writes stay in /config and /tmp.
# /data and /etc/letsencrypt become symlinks into the /config volume.
RUN set -eux; \
    sed -i -e '/^user /d' -e 's|^pid .*|pid /tmp/nginx/nginx.pid;|' /etc/nginx/nginx.conf; \
    grep -rl '/var/cache/nginx' /etc/nginx | xargs -r sed -i 's|/var/cache/nginx|/tmp/nginx/cache|g'; \
    ln -s /config/data /data; \
    ln -s /config/letsencrypt /etc/letsencrypt; \
    chmod -R a+rX /app/npm /etc/nginx /usr/local/openresty /var/www/html

# certbot in the base venv. start.sh seeds a writable copy at /config/venv for DNS plugins.
# UNVERIFIED: DNS-challenge plugins are not installed here.
RUN /app/venv/bin/pip install --no-cache-dir "certbot==${CERTBOT_VERSION}"

ENV NODE_ENV=production \
    NODE_OPTIONS=--openssl-legacy-provider \
    HOME=/config

USER apps
COPY --chmod=0755 . /

WORKDIR /app/npm
EXPOSE 80 81 443
VOLUME /config

CMD ["/start.sh"]
