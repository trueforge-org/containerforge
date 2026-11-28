FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
USER root

# Caches and npm/git scratch go to /tmp, never /config.
ENV \
  HOME=/tmp \
  NPM_CONFIG_CACHE=/tmp/.npm \
  NPM_CONFIG_UPDATE_NOTIFIER=false \
  NPM_CONFIG_FUND=false \
  NPM_CONFIG_AUDIT=false \
  PATH=/app/hexo-cli/node_modules/.bin:$PATH

# The starter blog is baked into /app so first start works without network.
# hexo init runs with --no-install; dependencies are installed by npm below.
# UNVERIFIED: hexo init clones hexo-starter from git at build time; a failed clone
# only warns in hexo-cli and falls back to bundled assets. Check the starter content.
RUN echo "*** Installing hexo-cli ${VERSION} ***" && \
  mkdir -p /app/hexo-cli /usr/share/licenses/hexo-blog && \
  npm install --prefix /app/hexo-cli --omit=dev "hexo-cli@${VERSION}" && \
  echo "*** Baking hexo starter blog ***" && \
  hexo init --no-install /app/hexo-starter && \
  npm install --prefix /app/hexo-starter --omit=dev && \
  test -f /app/hexo-starter/node_modules/hexo/package.json && \
  echo "*** Copying license files ***" && \
  cp /app/hexo-cli/node_modules/hexo-cli/LICENSE /usr/share/licenses/hexo-blog/LICENSE-hexo-cli && \
  cp /app/hexo-starter/node_modules/hexo/LICENSE /usr/share/licenses/hexo-blog/LICENSE-hexo && \
  chown -R apps:apps /app && \
  chmod -R 755 /app && \
  echo "*** Cleaning Up ***" && \
  npm cache clean --force && \
  rm -rf /tmp/* /tmp/.npm

USER apps
COPY --chmod=0755 . /

EXPOSE 8080

WORKDIR /config
VOLUME /config
