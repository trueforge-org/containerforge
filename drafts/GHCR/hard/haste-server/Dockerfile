# UNVERIFIED: the upstream seejohnrun/haste-server is unreachable. This builds the nzzane fork,
# pinned by commit SHA (VERSION in docker-bake.hcl). The fork's node:14 base is EOL, so this uses python-node.
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

ARG VERSION

USER root

ENV NPM_CONFIG_CACHE=/tmp/npm

# No published checksum for GitHub commit archives. The commit SHA pins the content.
# Deviation from the fork Dockerfile: the extra storage drivers (redis, pg, memcached, aws-sdk, rethinkdbdash) are not installed.
RUN mkdir -p /app/haste-server && \
    curl -fsSL -o /tmp/haste-server.tar.gz "https://github.com/nzzane/haste-server/archive/${VERSION}.tar.gz" && \
    tar xzf /tmp/haste-server.tar.gz -C /app/haste-server --strip-components=1 && \
    rm -f /tmp/haste-server.tar.gz && \
    cd /app/haste-server && \
    npm install --omit=dev && \
    rm -rf /tmp/npm /tmp/*

COPY --chmod=0755 . /

ENV HOME=/config HOST=0.0.0.0 PORT=7777

USER apps

EXPOSE 7777
VOLUME /config

CMD ["/start.sh"]
