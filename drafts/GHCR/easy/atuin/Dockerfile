FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH

USER root

ENV \
  ATUIN_CONFIG_DIR=/config \
  RUST_LOG=atuin_server=info \
  TZ=Etc/UTC

RUN echo "*** Installing Atuin server ***" && \
  case "${TARGETARCH}" in \
    amd64) atuin_arch="x86_64" ;; \
    arm64) atuin_arch="aarch64" ;; \
    *) echo "Unsupported arch: ${TARGETARCH}" >&2; exit 1 ;; \
  esac && \
  asset="atuin-server-${atuin_arch}-unknown-linux-gnu.tar.gz" && \
  base="https://github.com/atuinsh/atuin/releases/download/v${VERSION}" && \
  mkdir -p /tmp/atuin-extract /app/atuin /config && \
  curl -fsSL -o "/tmp/${asset}" "${base}/${asset}" && \
  curl -fsSL -o "/tmp/${asset}.sha256" "${base}/${asset}.sha256" && \
  (cd /tmp && sha256sum -c "${asset}.sha256") && \
  tar -xzf "/tmp/${asset}" -C /tmp/atuin-extract && \
  install -m 0755 "$(find /tmp/atuin-extract -type f -name atuin-server | head -n 1)" /app/atuin/atuin-server && \
  chown -R apps:apps /app/atuin /config && \
  echo "*** Cleaning Up ***" && \
  rm -rf /tmp/atuin-extract "/tmp/${asset}" "/tmp/${asset}.sha256"

USER apps
COPY --chmod=0755 . /

EXPOSE 8888

VOLUME /config

WORKDIR /app/atuin

ENTRYPOINT ["/start.sh"]
