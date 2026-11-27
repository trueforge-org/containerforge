FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
USER root

ENV HOME=/config \
  GITEA_WORK_DIR=/config/gitea \
  GITEA_CUSTOM=/config/gitea/custom \
  GITEA_APP_INI=/config/gitea/app.ini \
  GITEA_TEMP=/tmp/gitea \
  TMPDIR=/tmp/gitea

# Checksums from the upstream .sha256 files for v28.4.0. Update them together with VERSION.
RUN echo "*** Installing Gitea ***" && \
  case "${TARGETARCH}" in \
    amd64) gitea_sha="154e775bd6bb589fc14cd93a689d8fbc64090aaa3ec537f0e3af298b13c6d386" ;; \
    arm64) gitea_sha="5f8aad6a9fdb115170afc6691cb7dcb5f492dea82c5224385622cff093f66dbb" ;; \
    *) echo "Unsupported architecture: ${TARGETARCH}" >&2; exit 1 ;; \
  esac && \
  asset="gitea-${VERSION}-linux-${TARGETARCH}" && \
  curl -fsSL -o "/tmp/${asset}" \
    "https://github.com/go-gitea/gitea/releases/download/v${VERSION}/${asset}" && \
  echo "${gitea_sha}  /tmp/${asset}" | sha256sum -c - && \
  mkdir -p /app/gitea && \
  install -m 0755 "/tmp/${asset}" /app/gitea/gitea && \
  echo "*** Installing license (release binary does not ship LICENSE, so fetch it from the tag) ***" && \
  mkdir -p /usr/share/licenses/gitea && \
  curl -fsSL -o /usr/share/licenses/gitea/LICENSE \
    "https://raw.githubusercontent.com/go-gitea/gitea/v${VERSION}/LICENSE" && \
  echo "*** Cleaning Up ***" && \
  rm -f "/tmp/${asset}"

USER apps
COPY --chmod=0755 . /

EXPOSE 3000 2222

VOLUME /config

CMD ["/start.sh"]
