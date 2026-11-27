# Upstream: diamkil/socials @ 2b7a17b (node:lts-alpine, yarn, runs as root).
# Adapted: glibc python-node base, example profiles moved to /defaults, data in /config, USER apps.

FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

ARG VERSION
USER root

ENV PORT=7574 \
  DEFID=default \
  YARN_CACHE_FOLDER=/tmp/.yarn-cache \
  npm_config_cache=/tmp/.npm

# The source is pinned by commit SHA (no releases or tags upstream).
# UNVERIFIED: yarn.lock is committed upstream, so --frozen-lockfile can be used.
RUN echo "*** Installing socials ***" && \
  npm install -g yarn@1.22.22 && \
  mkdir -p /app/socials /defaults && \
  curl -fsSL -o /tmp/socials.tar.gz \
    "https://github.com/diamkil/socials/archive/${VERSION}.tar.gz" && \
  tar xf /tmp/socials.tar.gz -C /app/socials --strip-components=1 && \
  rm /tmp/socials.tar.gz && \
  cd /app/socials && \
  yarn install --frozen-lockfile && \
  yarn build && \
  yarn install --production --frozen-lockfile && \
  echo "*** Moving example profiles out of the app tree ***" && \
  mv /app/socials/people /defaults/people && \
  ln -s /config/people /app/socials/people && \
  chmod -R a+rX /app/socials /defaults && \
  echo "*** Cleaning Up ***" && \
  rm -rf /tmp/* /root/.cache /var/lib/apt/lists/*

USER apps
COPY --chmod=0755 . /

EXPOSE 7574

VOLUME /config

WORKDIR /app/socials
