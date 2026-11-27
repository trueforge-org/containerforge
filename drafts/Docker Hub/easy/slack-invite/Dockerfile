FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

ARG VERSION

USER root

# UNVERIFIED: curl is assumed to be in the base image; the upstream deps are old (jade 1.x, i18n 0.7, request), check the build on this Node.
# sed stops i18n writing missing keys into the read-only app dir; grep makes the build fail if upstream app.js changes.
RUN mkdir -p /app/slack-invite /usr/share/licenses/slack-invite && \
    curl -fsSL "https://github.com/ninthwalker/slack-invite/archive/${VERSION}.tar.gz" \
      | tar xz -C /app/slack-invite --strip-components=1 && \
    cd /app/slack-invite && \
    sed -i "s#autoReload: true#autoReload: false,\n    updateFiles: false#" app.js && \
    grep -q 'updateFiles: false' app.js && \
    npm install --omit=dev --no-audit --no-fund --cache /tmp/npm-cache && \
    cp LICENSE.md /usr/share/licenses/slack-invite/ && \
    rm -rf /tmp/npm-cache /root/.npm && \
    chown -R root:root /app && \
    chmod -R 755 /app

ENV NODE_ENV=production \
    HOME=/config \
    npm_config_cache=/tmp/npm-cache

USER apps
COPY --chmod=0755 . /

EXPOSE 7879

VOLUME /config
WORKDIR /config

CMD ["/start.sh"]
