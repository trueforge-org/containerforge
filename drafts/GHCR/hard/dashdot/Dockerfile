# Initial draft from plan.md. Not built or tested.
# UNVERIFIED: Node and Yarn versions in the python-node base (plan section 3). Check before relying on them.

############## build ##############
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5 AS build

ARG VERSION
ARG TARGETARCH
# UNVERIFIED: no upstream checksums. Compute on the first verified download and pin here (self-computed).
ARG SHA256_SOURCE=""
ARG SHA256_OOKLA_AMD64=""
ARG SHA256_OOKLA_ARM64=""

USER root

RUN set -eux; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      ca-certificates \
      curl; \
    rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    mkdir -p /tmp/src; \
    curl -fL -o /tmp/dashdot.tar.gz "https://github.com/MauriceNino/dashdot/archive/refs/tags/v${VERSION}.tar.gz"; \
    echo "${SHA256_SOURCE}  /tmp/dashdot.tar.gz" | sha256sum -c -; \
    tar xzf /tmp/dashdot.tar.gz -C /tmp/src --strip-components=1; \
    rm -f /tmp/dashdot.tar.gz

# Ookla speedtest CLI. Only used when DASHDOT_ACCEPT_OOKLA_EULA=true. arm/v7 is out of scope.
RUN set -eux; \
    case "${TARGETARCH}" in \
      amd64) ookla_arch=x86_64; sha="${SHA256_OOKLA_AMD64}" ;; \
      arm64) ookla_arch=aarch64; sha="${SHA256_OOKLA_ARM64}" ;; \
      *) echo "unsupported arch: ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    curl -fL -o /tmp/speedtest.tgz "https://install.speedtest.net/app/cli/ookla-speedtest-1.1.1-linux-${ookla_arch}.tgz"; \
    echo "${sha}  /tmp/speedtest.tgz" | sha256sum -c -; \
    tar xzf /tmp/speedtest.tgz -C /usr/local/bin speedtest; \
    rm -f /tmp/speedtest.tgz

# Caches stay in /tmp. Nothing is written under /config (the app has no persistent state).
ENV NODE_ENV=production \
    COREPACK_HOME=/tmp/corepack \
    YARN_CACHE_FOLDER=/tmp/yarn-cache \
    npm_config_cache=/tmp/npm-cache

WORKDIR /tmp/src
RUN set -eux; \
    corepack enable; \
    yarn --immutable; \
    yarn build:prod; \
    node scripts/strip_package_json.js

# Stage the runtime tree the way upstream's prod stage does, under /app/dashdot.
# UNVERIFIED: the production install (`yarn` in the staged tree) on this layout.
RUN set -eux; \
    mkdir -p /app/dashdot/server/dist /app/dashdot/view/dist /app/dashdot/cli/dist /app/dashdot/.yarn /usr/share/licenses/dashdot; \
    cp -r /tmp/src/apps/server/dist/. /app/dashdot/server/dist/; \
    cp -r /tmp/src/apps/view/dist/. /app/dashdot/view/dist/; \
    cp -r /tmp/src/apps/cli/dist/. /app/dashdot/cli/dist/; \
    cp /tmp/src/dist/package.json /app/dashdot/package.json; \
    cp -r /tmp/src/.yarn/releases /app/dashdot/.yarn/; \
    cp /tmp/src/.yarnrc.yml /app/dashdot/; \
    printf '{"version":"%s","buildhash":"unknown"}\n' "${VERSION}" > /app/dashdot/version.json; \
    cp /tmp/src/LICENSE /usr/share/licenses/dashdot/LICENSE; \
    cd /app/dashdot; \
    yarn

############## runtime ##############
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

USER root

# Host detail tools from upstream's apk list. UNVERIFIED: apt package names on this base.
# Useful host data also needs privileges that the plan does not grant (plan section 9).
RUN set -eux; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      util-linux \
      mdadm \
      dmidecode \
      lm-sensors; \
    rm -rf /var/lib/apt/lists/*

COPY --from=build /app/dashdot /app/dashdot
COPY --from=build /usr/local/bin/speedtest /usr/local/bin/speedtest
COPY --from=build /usr/share/licenses/dashdot/LICENSE /usr/share/licenses/dashdot/LICENSE

ENV NODE_ENV=production \
    DASHDOT_RUNNING_IN_DOCKER=true \
    DASHDOT_PORT=3001 \
    HOME=/tmp

USER apps
COPY --chmod=0755 . /

EXPOSE 3001

WORKDIR /app/dashdot
