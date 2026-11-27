FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5 AS build

ARG VERSION

USER root

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV PNPM_HOME=/tmp/pnpm \
    PATH=/tmp/pnpm:$PATH \
    NEXT_TELEMETRY_DISABLED=1 \
    NPM_CONFIG_CACHE=/tmp/npm-cache

# UNVERIFIED: corepack in the python-node base (plan section 3). Fallback: npm install -g pnpm@10.25.0
# UNVERIFIED: the tag v6.1.2 points at commit 7ad39fd. Latest upstream release is v6.2.0 (see plan notes).
RUN mkdir -p /tmp/src && \
    curl -fsSL "https://github.com/Brandawg93/PeaNUT/archive/refs/tags/${VERSION}.tar.gz" | tar xz -C /tmp/src --strip-components=1 && \
    cd /tmp/src && \
    corepack enable && \
    pnpm i --frozen-lockfile --ignore-scripts && \
    pnpm run next-ws && \
    pnpm run build && \
    rm -rf /tmp/src/.next/standalone/.next/cache

FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

ARG VERSION

USER root

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

COPY --from=build /tmp/src/.next/standalone/ /app/
COPY --from=build /tmp/src/.next/static/ /app/.next/static/
COPY --from=build /tmp/src/src/app/api/ /app/src/app/api/
COPY --from=build /tmp/src/package.json /app/package.json
# entrypoint.mjs and healthcheck.mjs come from the tag tarball (repo root), not from apps/peanut/
COPY --from=build --chmod=0755 /tmp/src/entrypoint.mjs /tmp/src/healthcheck.mjs /app/
COPY --from=build /tmp/src/LICENSE /usr/share/licenses/peanut/LICENSE

# hadolint ignore=DL3008
RUN install -d -o apps -g apps /config && \
    chmod -R a+rX /app && \
    rm -rf /tmp/* /tmp/.[!.]* /var/lib/apt/lists/*

ENV NODE_ENV=production \
    CI=true \
    WEB_HOST=0.0.0.0 \
    WEB_PORT=8080 \
    BASE_PATH="" \
    SETTINGS_FILE=/config/settings.yml \
    AUTH_FILE_PATH=/config/auth.yaml \
    DEBUG=false

USER apps
COPY --chmod=0755 . /

EXPOSE 8080
VOLUME /config
WORKDIR /app

CMD ["/start.sh"]
