FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

ARG VERSION
ARG TARGETARCH
# UNVERIFIED: no checksum is published upstream. Record the SHA-256 of MySpeed-${VERSION}.zip in the PR and pin it here.
ARG MYSPEED_ZIP_SHA256=
USER root

ENV TZ=Etc/UTC \
  HOME=/config

# UNVERIFIED: unzip is not assumed present in the base, so the archive is extracted with Python's zipfile module.
RUN curl -fL -o /tmp/myspeed.zip \
    "https://github.com/gnmyt/myspeed/releases/download/v${VERSION}/MySpeed-${VERSION}.zip" && \
  echo "${MYSPEED_ZIP_SHA256}  /tmp/myspeed.zip" | sha256sum -c - && \
  mkdir -p /app/myspeed && \
  python3 -m zipfile -e /tmp/myspeed.zip /app/myspeed && \
  # UNVERIFIED: if the zip ships no built client or node_modules, run `npm ci --omit=dev` here with npm_config_cache=/tmp/npm
  # UNVERIFIED: LICENSE may not be inside the zip; fall back to the MIT text from the GitHub repo if it is missing
  install -D /app/myspeed/LICENSE /usr/share/licenses/myspeed/LICENSE && \
  # Data lives in /config; the symlink is dangling until start.sh creates /config/data
  ln -s /config/data /app/myspeed/data && \
  chown -R apps:apps /app/myspeed && \
  chmod -R 755 /app/myspeed && \
  rm -rf /tmp/*

USER apps
COPY --chmod=0755 . /

WORKDIR /app/myspeed
EXPOSE 5216
VOLUME /config
