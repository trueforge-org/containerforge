FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

ARG VERSION
ARG TARGETARCH
USER root

# UNVERIFIED: cloudcmd needs node >=22. Check the Node major in python-node with `node --version` on the built image.
# npm verifies the registry integrity (sha512) of cloudcmd@${VERSION} on install.
# UNVERIFIED: node-pty (terminal feature, off by default) may compile here if no prebuild exists for this arch.
RUN mkdir -p /app/cloudcommander && \
    npm install \
      --prefix /app/cloudcommander \
      --omit=dev \
      --no-audit \
      --no-fund \
      "cloudcmd@${VERSION}" && \
    mkdir -p /usr/share/licenses/cloudcommander && \
    cp /app/cloudcommander/node_modules/cloudcmd/LICENSE /usr/share/licenses/cloudcommander/LICENSE && \
    npm cache clean --force && \
    chown -R root:root /app/cloudcommander && \
    chmod -R 755 /app/cloudcommander && \
    mkdir -p /config && \
    chown -R apps:apps /config && \
    rm -rf /tmp/* /root/.npm

ENV \
  HOME=/config \
  NPM_CONFIG_CACHE=/tmp/npm

USER apps
COPY --chmod=0755 . /

EXPOSE 8000

VOLUME /config

WORKDIR /config
