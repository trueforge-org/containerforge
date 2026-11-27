# hadolint ignore=DL3007
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

ARG VERSION

USER root

# UNVERIFIED: this base is expected to provide node, npm and curl. Confirm with `node --version`, `yarn --version` and `command -v curl` in the built image.
# The Discord bot does not listen on a port (outbound gateway only), so there is no EXPOSE.
RUN mkdir -p /app && \
    curl -fsSL -o /tmp/retrobot.tar.gz "https://github.com/rossimo/retrobot/archive/${VERSION}.tar.gz" && \
    tar xzf /tmp/retrobot.tar.gz -C /app --strip-components=1 && \
    rm -f /tmp/retrobot.tar.gz

# Install yarn only if the base does not already have it. UNVERIFIED: the yarn version is not pinned yet.
# UNVERIFIED: --frozen-lockfile assumes a yarn.lock at the pinned commit.
RUN command -v yarn >/dev/null 2>&1 || npm install -g yarn; \
    cd /app && \
    YARN_CACHE_FOLDER=/tmp/yarn yarn install --frozen-lockfile && \
    rm -rf /tmp/yarn

# The bot writes its data under /app/data (README: /retrobot/data). Link it into /config at build time,
# so the runtime never writes to /app. start.sh creates the target.
# UNVERIFIED: the data path is documented in the README (volume mount), not confirmed in the source code.
RUN mkdir -p /usr/share/licenses/retrobot && \
    cp /app/LICENSE /usr/share/licenses/retrobot/LICENSE && \
    ln -s /config/data /app/data && \
    chown -R root:root /app && \
    chmod -R 755 /app && \
    rm -rf /tmp/* /var/tmp/*

ENV HOME=/tmp

USER apps
COPY --chmod=0755 . /

WORKDIR /app
VOLUME ["/config"]

CMD ["/start.sh"]
