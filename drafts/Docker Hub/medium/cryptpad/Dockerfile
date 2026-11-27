# Initial draft from drafts/Docker Hub/medium/cryptpad/plan.md. Not built yet.
# DECISION (from plan): VERSION 2026.10.1 is the recommended build. The user must confirm it before merge.

FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

ARG VERSION
ARG TARGETARCH
USER root
ENV HOME=/config

RUN echo "**** download cryptpad ****" && \
    mkdir -p /app/cryptpad && \
    curl -fL -o /tmp/cryptpad.tar.gz \
        "https://github.com/cryptpad/cryptpad/archive/refs/tags/${VERSION}.tar.gz" && \
    tar xzf /tmp/cryptpad.tar.gz -C /app/cryptpad --strip-components=1 && \
    rm -f /tmp/cryptpad.tar.gz
# UNVERIFIED: no checksum is published. The tag tarball is not content-pinned.

RUN echo "**** build cryptpad ****" && \
    cd /app/cryptpad && \
    npm_config_cache=/tmp/npm npm install --production && \
    npm_config_cache=/tmp/npm npm run install:components && \
    npm_config_cache=/tmp/npm npm run build && \
    rm -rf /tmp/npm /tmp/*
# UNVERIFIED: the upstream Dockerfile sets installMethod with a sed. Copy that step from the chosen tag before the first build.
# UNVERIFIED: Node major in python-node against the CryptPad engines field.

RUN echo "**** move config and data to /config ****" && \
    mkdir -p /config /usr/share/licenses/cryptpad && \
    cd /app/cryptpad && \
    mv config config.default && \
    for d in blob block customize data datastore; do rm -rf "$d" && ln -s "/config/$d" "$d"; done && \
    ln -s /config/config config && \
    cp /app/cryptpad/LICENSE /usr/share/licenses/cryptpad/LICENSE && \
    chown apps:apps /config && \
    chown -R apps:apps /app/cryptpad && \
    chmod -R 755 /app/cryptpad
# UNVERIFIED: the LICENSE file path at the chosen tag (present at commit cbeb1b76).

USER apps
COPY --chmod=0755 . /

EXPOSE 3000
VOLUME /config
WORKDIR /app/cryptpad
