# Base per plan.md (python-node kept for the Node runtime). UNVERIFIED: the repo base table lists ubuntu for Node-only apps.
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

ARG VERSION
ARG TARGETARCH
# SHA256 of the release zips for VERSION, from the GitHub release asset digests (plan.md).
ARG ZWAVEJS_SHA256_AMD64="edac9b12c233d8aaa5234d636e53c313c414ec3990dd4b91e14a16444e69dca9"
ARG ZWAVEJS_SHA256_ARM64="2acfc40bb67a64e4233cda5602d0c378194cee9abc4d7b21fcff33d4dae78ba8"
USER root

ENV \
  HOME=/config \
  NODE_ENV=production

# UNVERIFIED: zip layout and LICENSE path are not inspected yet. unzip is installed only if the base lacks it.
RUN set -eu; \
  case "$TARGETARCH" in \
    amd64) zip_name="zwave-js-ui-v${VERSION}-linux.zip"; zip_sha="${ZWAVEJS_SHA256_AMD64}" ;; \
    arm64) zip_name="zwave-js-ui-v${VERSION}-linux-arm64.zip"; zip_sha="${ZWAVEJS_SHA256_ARM64}" ;; \
    *) echo "unsupported arch: ${TARGETARCH}" >&2; exit 1 ;; \
  esac; \
  if ! command -v unzip >/dev/null 2>&1; then \
    apt-get update && \
    apt-get install -y --no-install-recommends unzip && \
    rm -rf /var/lib/apt/lists/*; \
  fi; \
  echo "*** Installing zwave-js-ui ${VERSION} ***"; \
  curl -fL -o /tmp/zwave-js-ui.zip \
    "https://github.com/zwave-js/zwave-js-ui/releases/download/v${VERSION}/${zip_name}"; \
  echo "${zip_sha}  /tmp/zwave-js-ui.zip" | sha256sum -c -; \
  mkdir -p /app/zwave-js-ui; \
  unzip -q /tmp/zwave-js-ui.zip -d /app/zwave-js-ui; \
  install -D -m0644 /app/zwave-js-ui/LICENSE /usr/share/licenses/zwavejs2mqtt/LICENSE; \
  rm -f /tmp/zwave-js-ui.zip

USER apps
COPY --chmod=0755 . /

# 3000 (websocket, chart targetPort) is not added: it is unverified upstream.
EXPOSE 8091

VOLUME /config
