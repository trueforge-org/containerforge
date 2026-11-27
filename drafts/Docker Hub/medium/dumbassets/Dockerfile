FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

ARG VERSION
USER root

# npm and pip caches go to /tmp. Apprise goes into the bundled /app/venv, which is read-only at runtime.
ENV \
  HOME=/tmp \
  NPM_CONFIG_CACHE=/tmp/.npm \
  NODE_ENV=production \
  PATH="/app/venv/bin:${PATH}"

# No upstream checksum is published for the tag archive. Integrity comes from npm ci and the committed package-lock.json.
# UNVERIFIED: Apprise is not pinned. Pin it with a renovate-annotated variable if reproducible builds are wanted.
RUN echo "*** Installing DumbAssets ${VERSION} ***" && \
  mkdir -p /app/dumbassets /usr/share/licenses/dumbassets && \
  curl -fsSL -o \
    /tmp/dumbassets.tar.gz \
    "https://github.com/DumbWareio/DumbAssets/archive/refs/tags/v${VERSION}.tar.gz" && \
  tar xzf \
    /tmp/dumbassets.tar.gz -C \
    /app/dumbassets --strip-components=1 && \
  cd /app/dumbassets && \
  npm ci --omit=dev && \
  cp LICENSE /usr/share/licenses/dumbassets/LICENSE && \
  echo "*** Installing Apprise ***" && \
  /app/venv/bin/pip install --no-cache-dir apprise && \
  echo "*** Redirecting data to /config ***" && \
  rm -rf /app/dumbassets/data && \
  ln -s /config /app/dumbassets/data && \
  echo "*** Setting permissions ***" && \
  chown -R apps:apps /app && chmod -R 755 /app && \
  echo "*** Cleaning Up ***" && \
  npm cache clean --force && \
  rm -rf /tmp/*

USER apps
COPY --chmod=0755 . /

WORKDIR /app/dumbassets

EXPOSE 3000

VOLUME /config
