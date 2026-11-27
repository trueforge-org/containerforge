# hadolint ignore=DL3007
# UNVERIFIED: build stage. The whole monorepo build (yarn 1 + turbo) has not been run.
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5 AS build

ARG VERSION
ARG XO_REF

USER root
WORKDIR /app/xen-orchestra

# UNVERIFIED: libfuse-dev is a guess for native modules. Check the upstream Dockerfile before merge.
# hadolint ignore=DL3008,DL3015
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        curl \
        libfuse-dev \
        libpng-dev \
        pkg-config \
        python3 \
    && rm -rf /var/lib/apt/lists/*

# Build caches go to /tmp.
ENV HOME=/tmp \
    YARN_CACHE_FOLDER=/tmp/yarn \
    npm_config_cache=/tmp/npm \
    TURBO_TELEMETRY_DISABLED=1

# The source is pinned to a commit, because the version tags do not match the xo-server package version.
RUN curl -fsSL "https://github.com/vatesfr/xen-orchestra/archive/${XO_REF}.tar.gz" -o /tmp/xo.tar.gz && \
    tar xzf /tmp/xo.tar.gz --strip-components=1 -C /app/xen-orchestra && \
    rm -f /tmp/xo.tar.gz

# UNVERIFIED: yarn 1.22.22 may already be in the base. Install it only if it is missing.
RUN command -v yarn >/dev/null 2>&1 || npm i -g yarn@1.22.22

# Build. The paths are the same as in the final image, because the plugin symlinks use absolute targets.
RUN yarn config set network-timeout 200000 && \
    yarn install --frozen-lockfile && \
    yarn build && \
    rm -rf /tmp/*

# Fails when XO_REF is not the commit for VERSION (see docker-bake.hcl). UNVERIFIED: the commit
# e9760747 reports xo-server 5.214.0, so this check will fail until XO_REF is changed to a 5.213.0 commit.
RUN test "$(node -p "require('./packages/xo-server/package.json').version")" = "${VERSION}"

# Plugins are symlinked into xo-server/node_modules, as upstream does.
RUN cd /app/xen-orchestra/packages && \
    for d in */; do \
      p="${d%/}"; \
      case "$p" in \
        xo-server|xo-web|xo-server-cloud|xo-server-test|xo-server-test-plugin) continue ;; \
      esac; \
      ln -sfn "/app/xen-orchestra/packages/$p" "/app/xen-orchestra/packages/xo-server/node_modules/$p"; \
    done

# ---------------------------------------------------------------------------
# UNVERIFIED: valkey replaces the redis-server of the upstream image. Package availability on 26.04 is not checked.
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

ARG VERSION
ARG VALKEY_PACKAGE_VERSION

USER root

# envsubst comes from gettext-base. UNVERIFIED: the plan says it is in the base. Add the package only if the base lacks it.
# hadolint ignore=DL3008,DL3015
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        "valkey-server=${VALKEY_PACKAGE_VERSION}" \
        "valkey-tools=${VALKEY_PACKAGE_VERSION}" \
        cifs-utils \
        libfuse2t64 \
        libvhdi-utils \
        libxml2 \
        lvm2 \
        netbase \
        nfs-common \
        ntfs-3g \
        procps \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --from=build /app/xen-orchestra /app/xen-orchestra

# No LICENSE file exists upstream. AGPL-3.0 text is copied from the system copy if present.
# UNVERIFIED: the plan suggests fetching the AGPL text from gnu.org with a checksum when the system copy is missing.
RUN mkdir -p /usr/share/licenses/xen-orchestra && \
    cp /app/xen-orchestra/README.md /usr/share/licenses/xen-orchestra/README.md && \
    if [ -f /usr/share/common-licenses/AGPL-3 ]; then cp /usr/share/common-licenses/AGPL-3 /usr/share/licenses/xen-orchestra/LICENSE; fi

ENV HOME=/config \
    HTTP_PORT=8080 \
    XO_REDIS_URI="" \
    TZ=Etc/UTC

USER apps
COPY --chmod=0755 . /

EXPOSE 8080

VOLUME /config
WORKDIR /app/xen-orchestra/packages/xo-server

CMD ["/start.sh"]
