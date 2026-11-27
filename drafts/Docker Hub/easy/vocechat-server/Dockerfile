
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION
ARG TARGETARCH
# UNVERIFIED: these release digests come from the plan and were not checked against the release assets.
# If the build fails on sha256sum, re-read the digests from the GitHub release API and fix them here and in docker-bake.hcl.
ARG SHA256_AMD64=a5ec5106a2eb2433aed60777cd2a53b23236f28974d16264161c00e28845e049
ARG SHA256_ARM64=04f51c9656f0c040892c73562ef63794752e7d0fa610683052e10a0b3e4e73ac
USER root

ENV \
  HOME=/config

RUN echo "*** Installing VoceChat server ${VERSION} ***" && \
  case "${TARGETARCH}" in \
    amd64) ARCH=x86_64; SUM="${SHA256_AMD64}" ;; \
    arm64) ARCH=aarch64; SUM="${SHA256_ARM64}" ;; \
    *) echo "unsupported architecture: ${TARGETARCH}" >&2; exit 1 ;; \
  esac && \
  curl -fsSL -o /tmp/vocechat.zip \
    "https://github.com/Privoce/vocechat-server-rust/releases/download/v${VERSION#v}/vocechat-server-v${VERSION#v}-${ARCH}-unknown-linux-musl.zip" && \
  echo "${SUM}  /tmp/vocechat.zip" | sha256sum -c - && \
  mkdir -p /app/vocechat /usr/share/licenses/vocechat-server && \
  unzip -q /tmp/vocechat.zip -d /app/vocechat && \
  chmod 0755 /app/vocechat/vocechat-server && \
  # UNVERIFIED: no LICENSE file is published upstream. This notice records the terms from the upstream README.
  printf '%s\n' \
    "VoceChat server (vocechat-server) ${VERSION}" \
    "Source: https://github.com/Privoce/vocechat-server-rust" \
    "No LICENSE file is published upstream. The upstream README describes the Big Time Public License:" \
    "free for personal use with up to 20 registered users, a paid license is required beyond that." \
    > /usr/share/licenses/vocechat-server/README && \
  chown -R apps:apps /app && \
  chmod -R 755 /app && \
  rm -f /tmp/vocechat.zip

USER apps
COPY --chmod=0755 . /

EXPOSE 3000

VOLUME /config

WORKDIR /config
