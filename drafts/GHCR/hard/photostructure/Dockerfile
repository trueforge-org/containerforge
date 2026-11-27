# Draft from plan.md (photostructure). Not built or tested. UNVERIFIED items are marked.
# BLOCKERS (plan section 10): the licence is proprietary, the version (beta or 2026.10.3) is to be decided, and the start command is not verified.
# Registry integrity for photostructure@2026.10.3 (plan section 1, not checked by this draft):
#   sha512-egPc2OOs129dMYXXVB2wgeBs9RknpJCfDgti1angAO1jZcsCdw5UPt5x8DFb/cUhadqK9YDR6VleqxZBvSdwDA==

FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5 AS build

ARG VERSION

USER root
ENV npm_config_cache=/tmp/npm
# UNVERIFIED: build tools are needed only if a native module does not ship a prebuilt binary. Build stage only.
RUN apt-get update && \
  apt-get install -y --no-install-recommends build-essential python3 && \
  rm -rf /var/lib/apt/lists/*
RUN npm install --omit=dev --no-audit --no-fund --prefix /opt/photostructure "photostructure@${VERSION}"


FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

USER root
# Not copied from upstream: tini and wget (already in the base), and the passwd/usermod tooling (the base runs as apps).
# UNVERIFIED: package names and versions on this base.
RUN apt-get update && \
  apt-get install -y --no-install-recommends \
    libjpeg-turbo-progs locales-all perl procps ripgrep tzdata && \
  rm -rf /var/lib/apt/lists/*

COPY --from=build /opt/photostructure /opt/photostructure

# UNVERIFIED: the licence path inside the npm package. The npm licence field is "SEE LICENSE IN LICENSE.md".
# /.running-in-container replaces PS_IS_DOCKER in the upstream image (plan section 9). Confirm it is still needed.
RUN mkdir -p /usr/share/licenses/photostructure && \
  cp /opt/photostructure/node_modules/photostructure/LICENSE.md /usr/share/licenses/photostructure/LICENSE.md && \
  touch /.running-in-container && \
  chmod -R a=rX /opt/photostructure

# UNVERIFIED: PS_LOG_STDOUT and PS_NO_PUID_CHOWN names (plan section 1). PIXI_HOME in /config is an open decision (plan section 10).
ENV PATH="/opt/photostructure/node_modules/.bin:${PATH}" \
  HOME=/config \
  PS_CONFIG_DIR=/config/system \
  PS_LIBRARY_DIR=/config/library \
  PS_HTTP_PORT=1787 \
  PS_LOG_STDOUT=1 \
  PS_NO_PUID_CHOWN=1 \
  PIXI_HOME=/config/pixi

USER apps
COPY --chmod=0755 . /

# The base image entrypoint (tini, then /entrypoint.sh, then /start.sh) is inherited. No ENTRYPOINT or CMD here.
EXPOSE 1787
VOLUME /config
