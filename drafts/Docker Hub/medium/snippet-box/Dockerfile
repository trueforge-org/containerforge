# hadolint ignore=DL3007
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

ARG VERSION
ARG TARGETARCH

ENV NODE_ENV=production \
    PORT=5000 \
    HOME=/config

USER root

# Build tools for the native Node modules (sqlite3, node-sass). Removed again at the end of this layer.
# UNVERIFIED: the Node major in this base must be compatible with node-sass and sqlite3. Check `node -v` and the build.
# hadolint ignore=DL3008,DL3015
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        python3 \
        python3-dev \
        python-is-python3 \
    && rm -rf /var/lib/apt/lists/*

# Fetch the source at the pinned commit, install, and build the server and the React client.
# UNVERIFIED: the source archive has no published checksum. The commit SHA in VERSION is the pin.
RUN mkdir -p /app/snippet-box \
    && curl -fsSL -o /tmp/snippet-box.tar.gz "https://github.com/pawelmalak/snippet-box/archive/${VERSION}.tar.gz" \
    && tar -xzf /tmp/snippet-box.tar.gz -C /app/snippet-box --strip-components=1 \
    && rm -f /tmp/snippet-box.tar.gz \
    && cd /app/snippet-box \
    && npm install \
    && npm run build \
    && npm prune --omit=dev

# Ship the upstream licence. UNVERIFIED: the upstream filename (believed to be LICENCE.md). Confirm in the tarball.
RUN mkdir -p /usr/share/licenses/snippet-box \
    && cp /app/snippet-box/LICENCE.md /usr/share/licenses/snippet-box/LICENSE.md

# SQLite writes data/db.sqlite3 relative to the working directory. Point data/ at the persistent volume.
RUN ln -s /config/data /app/snippet-box/data \
    && chown -R apps:apps /app/snippet-box \
    && chmod -R 755 /app/snippet-box \
    && npm cache clean --force \
    && apt-get purge -y --auto-remove build-essential python3-dev \
    && rm -rf /tmp/* /root/.npm /root/.cache /var/lib/apt/lists/*

COPY --chmod=0755 start.sh /start.sh

USER apps
COPY --chmod=0755 . /
WORKDIR /app/snippet-box

EXPOSE 5000
VOLUME /config

CMD ["/start.sh"]
