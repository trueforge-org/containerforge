
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

# set version label
ARG VERSION
# sha512 integrity of mongo-express-${VERSION}.tgz, from the npm registry dist.integrity
ARG NPM_INTEGRITY="sha512-GRn/eQmLplUfiq8AmwU2eqBhquAymIvEWhbQMALrbeb70/e8c5/pVisAr14FiPlBmhTTbUl0uqUSD1cx7d1aZg=="
USER root

# npm cache lives in /tmp, never /config or /app
ENV npm_config_cache=/tmp/npm-cache

# UNVERIFIED: the Node version in the python-node base must be >= 18.18 (npm engines).
# UNVERIFIED: the tarball ships LICENSE and no lockfile, so npm install is used instead of npm ci.
RUN \
  echo "**** fetch mongo-express ${VERSION} from npm ****" && \
  mkdir -p /app/mongo-express && \
  curl -fL -o /tmp/mongo-express.tgz \
    "https://registry.npmjs.org/mongo-express/-/mongo-express-${VERSION}.tgz" && \
  echo "**** verify npm integrity ****" && \
  test "sha512-$(openssl dgst -sha512 -binary /tmp/mongo-express.tgz | base64 -w0)" = "${NPM_INTEGRITY}" && \
  tar xzf /tmp/mongo-express.tgz -C /app/mongo-express --strip-components=1 && \
  echo "**** install runtime dependencies ****" && \
  cd /app/mongo-express && \
  npm install --omit=dev --no-audit --no-fund && \
  install -Dm0644 /app/mongo-express/LICENSE /usr/share/licenses/mongo-express/LICENSE && \
  npm cache clean --force && \
  rm -rf \
    /tmp/* \
    $HOME/.cache

# add local files
USER apps
COPY --chmod=0755 . /

# VCAP_APP_HOST matches upstream; the bind host is set in start.sh as well.
ENV PORT=8081 \
    VCAP_APP_HOST=0.0.0.0

EXPOSE 8081
VOLUME /config
WORKDIR /app/mongo-express
