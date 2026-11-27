FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

ARG VERSION
ARG VALETUDO_MAPPER_COMMIT

ENV \
  HOME=/tmp \
  NPM_CONFIG_CACHE=/tmp/npm-cache \
  NODE_ENV=production

USER root

# Upstream publishes no releases or tags, so the mapper is pinned to a commit.
# UNVERIFIED: the npm dependency tree is not locked upstream, so npm resolves fresh versions on each build.
RUN echo "*** Installing valetudo-mapper ***" && \
  mkdir -p /app/valetudo-mapper /usr/share/licenses/valetudo-mapper && \
  curl -fsSL "https://github.com/rand256/valetudo-mapper/archive/${VALETUDO_MAPPER_COMMIT}.tar.gz" | \
    tar xz -C /app/valetudo-mapper --strip-components=1 && \
  cp /app/valetudo-mapper/LICENSE /usr/share/licenses/valetudo-mapper/LICENSE && \
  cd /app/valetudo-mapper && \
  npm install --omit=dev && \
  npm cache clean --force && \
  chown -R root:root /app/valetudo-mapper && chmod -R a+rX /app/valetudo-mapper && \
  rm -rf /tmp/*

USER apps
COPY --chmod=0755 . /

EXPOSE 3000
VOLUME /config
WORKDIR /config
