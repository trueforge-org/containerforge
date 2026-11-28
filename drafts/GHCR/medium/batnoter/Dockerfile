# Build stage: the upstream UI is built with Node. The base's Node replaces upstream node:16 (end of life).
# UNVERIFIED: `npm run build` on this Node version; check on the first build.
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5 AS build

ARG VERSION

USER root

# Source tarball of the pinned tag (no release assets; no checksum published, the tag is pinned)
# UNVERIFIED: tarball URL not fetched; package-lock.json is in the tag (upstream used npm i)
RUN mkdir -p /tmp/src \
 && curl -fsSL "https://github.com/batnoter/batnoter/archive/refs/tags/v${VERSION}.tar.gz" \
      | tar xz -C /tmp/src --strip-components=1 \
 && cd /tmp/src \
 && npm ci \
 && npm run build

# Final stage
# UNVERIFIED: digest from the plan; the repo's it-tools and theme-park images use sha256:3a862278083a33d9ff969e987ee3a6ab24d2b928c35df07b2e69fa6f5d4e6cc1 for the same tag
FROM ghcr.io/trueforge-org/nginx:1.28.3@sha256:3a862278083a33d9ff969e987ee3a6ab24d2b928c35df07b2e69fa6f5d4e6cc1

ARG VERSION

USER root

COPY --from=build /tmp/src/build /app/batnoter/html
COPY --from=build /tmp/src/LICENSE /usr/share/licenses/batnoter/LICENSE

# run as 568
USER apps
COPY --chmod=0755 . /

ENV HOME=/config \
    XDG_CACHE_HOME=/tmp

EXPOSE 8080
VOLUME ["/config"]
WORKDIR /app/batnoter
CMD ["/start.sh"]
