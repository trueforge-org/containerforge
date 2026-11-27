# UNVERIFIED: base and digest taken from plan.md section 3 (python-node 3.15.2).
# Confirm the image provides Node and npm at the expected major version before the first build.
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

ARG VERSION
ARG TARGETARCH
USER root

ENV HOME=/config
ENV NODE_OPTIONS=--dns-result-order=ipv4first

# Install the pinned server package into /app/server at build time (/app is read-only at runtime).
# UNVERIFIED: ffmpeg or other apt packages are not installed here; add them only if the server needs them.
# UNVERIFIED: the LICENSE file path inside the npm package (the build fails if it is missing).
# UNVERIFIED: the volume symlink target; the upstream server writes ./volume relative to its install dir.
RUN \
  mkdir -p /app/server && \
  npm install --prefix /app/server --cache /tmp/npm-cache --no-audit --no-fund "@scrypted/server@${VERSION}" && \
  INSTALLED="$(node -p "require('/app/server/node_modules/@scrypted/server/package.json').version")" && \
  if [ "${INSTALLED}" != "${VERSION}" ]; then echo "version mismatch: ${INSTALLED} != ${VERSION}" >&2; exit 1; fi && \
  mkdir -p /usr/share/licenses/scrypted && \
  cp /app/server/node_modules/@scrypted/server/LICENSE /usr/share/licenses/scrypted/LICENSE && \
  ln -s /config/volume /app/server/volume && \
  rm -rf /tmp/npm-cache /tmp/*

COPY --chmod=0755 . /

USER apps

VOLUME /config
