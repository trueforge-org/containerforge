# hadolint ignore=DL3007
# UNVERIFIED: the upstream Dockerfile builds on alpine (musl). This draft builds on glibc, so the native sqlite3 module is rebuilt here.
# UNVERIFIED: the exact node version in the base. engines.node is 24.22.1 in the tag, so run `node -v` once.
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5 AS build

ARG VERSION
ARG SOURCE_SHA256

USER root
WORKDIR /app

# hadolint ignore=DL3008,DL3015
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        curl \
        git \
        libsqlite3-dev \
    && rm -rf /var/lib/apt/lists/*

# Source tarball, verified against the sha256 computed from the tag (upstream publishes no checksum).
RUN curl -fsSL "https://github.com/ferdium/ferdium-server/archive/refs/tags/v${VERSION}.tar.gz" -o /tmp/ferdium-server.tar.gz && \
    echo "${SOURCE_SHA256}  /tmp/ferdium-server.tar.gz" | sha256sum -c - && \
    mkdir -p /app/ferdi-server && \
    tar xzf /tmp/ferdium-server.tar.gz --strip-components=1 -C /app/ferdi-server && \
    rm -f /tmp/ferdium-server.tar.gz

# Caches go to /tmp, never to /config or /app.
ENV HOME=/tmp \
    CI=true \
    npm_config_cache=/tmp/npm \
    PNPM_HOME=/tmp/pnpm \
    npm_config_store_dir=/tmp/pnpm-store

# The pnpm version comes from the tag's package.json (engines.pnpm), so it follows VERSION.
# UNVERIFIED: upstream builds sqlite with `--config.build-from-source=sqlite --config.sqlite=...`; add those flags only if the install fails.
RUN cd /app/ferdi-server && \
    npm i -gf "pnpm@$(node -p 'require("./package.json").engines.pnpm')" && \
    pnpm -v && \
    pnpm install --frozen-lockfile && \
    pnpm build && \
    pnpm prune --prod && \
    rm -rf /tmp/*

# Recipes are cloned at build time (the tag has no recipe pin, so the image is not reproducible).
# The entrypoint of upstream pulls main at every start. This draft does not do that.
RUN git clone --depth 1 --branch main https://github.com/ferdium/ferdium-recipes /app/recipes-seed && \
    cd /app/recipes-seed && \
    npm i -gf "pnpm@$(node -p 'require("./package.json").engines.pnpm')" && \
    pnpm i && \
    pnpm package && \
    rm -rf /app/recipes-seed/.git /tmp/*

# ---------------------------------------------------------------------------
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

USER root
WORKDIR /app

# hadolint ignore=DL3008,DL3015
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libsqlite3-0 \
    && rm -rf /var/lib/apt/lists/*

# UNVERIFIED: @adonisjs/cli is unpinned, as in upstream. The version is installed globally here.
RUN npm_config_cache=/tmp/npm npm i -g @adonisjs/cli && \
    rm -rf /tmp/*

COPY --from=build /app/ferdi-server /app/ferdi-server
COPY --from=build /app/recipes-seed /app/recipes-seed

# The server reads ./recipes from its working directory. Point it at the persistent copy in /config.
RUN ln -s /config/recipes /app/ferdi-server/recipes && \
    mkdir -p /usr/share/licenses/ferdi-server && \
    cp /app/ferdi-server/LICENSE /usr/share/licenses/ferdi-server/LICENSE && \
    cp /app/recipes-seed/LICENSE.md /usr/share/licenses/ferdi-server/recipes-LICENSE.md

ENV HOST=0.0.0.0 \
    PORT=3333 \
    DATA_DIR=/config/data \
    HOME=/tmp \
    npm_config_cache=/tmp/npm \
    PNPM_HOME=/tmp/pnpm \
    npm_config_store_dir=/tmp/pnpm-store

USER apps
COPY --chmod=0755 . /

EXPOSE 3333

VOLUME /config
WORKDIR /app/ferdi-server

CMD ["/start.sh"]
