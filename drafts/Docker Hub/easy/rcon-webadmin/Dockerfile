FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

# set version label
ARG VERSION
USER root

# environment settings
# UNVERIFIED: Node.js version provided by this base image (plan section 3)
ENV \
  NODE_ENV=production \
  HOME=/tmp \
  npm_config_cache=/tmp/.npm

# Pure JavaScript app, so one source tarball serves both architectures.
# Checksum is the one computed from the release tarball (plan section 4).
RUN echo "*** Downloading rcon-web-admin ***" && \
  mkdir -p /app/rcon-web-admin && \
  curl -fsSL -o /tmp/rwa.tar.gz \
    "https://github.com/rcon-web-admin/rcon-web-admin/archive/${VERSION}.tar.gz" && \
  echo "b7e2dc23c2d10040214dd9c96f16ee7a9417a5a628ef2a1fae6cda25ad6bb59b  /tmp/rwa.tar.gz" | sha256sum -c - && \
  tar xzf /tmp/rwa.tar.gz -C /app/rcon-web-admin --strip-components=1 && \
  cd /app/rcon-web-admin && \
  echo "*** Installing npm dependencies (uses package-lock.json) ***" && \
  npm ci --omit=dev && \
  echo "*** Installing core widgets (fetched from GitHub master at build time) ***" && \
  node src/main.js install-core-widgets && \
  echo "*** Moving db to seed location and linking it to /config ***" && \
  mkdir -p db && \
  mv db /app/db-seed && \
  ln -s /config/db db && \
  echo "*** Adding license ***" && \
  mkdir -p /usr/share/licenses/rcon-web-admin && \
  cp LICENSE /usr/share/licenses/rcon-web-admin/ && \
  chown -R apps:apps /app && \
  chmod -R 755 /app && \
  rm -rf \
    /tmp/* \
    /root/.npm

# copy local files
USER apps
COPY --chmod=0755 . /

WORKDIR /app/rcon-web-admin

# ports and volumes
EXPOSE 4326 4327
VOLUME /config
