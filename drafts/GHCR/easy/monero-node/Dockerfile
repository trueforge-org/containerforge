FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
ARG MONERO_SHA256_AMD64
ARG MONERO_SHA256_ARM64

USER root

ENV \
  HOME=/config \
  TZ=Etc/UTC

RUN echo "*** Installing Monero CLI ***" && \
  case "${TARGETARCH}" in \
    amd64) monero_arch="linux-x64";   monero_sha="${MONERO_SHA256_AMD64}" ;; \
    arm64) monero_arch="linux-armv8"; monero_sha="${MONERO_SHA256_ARM64}" ;; \
    *) echo "Unsupported arch: ${TARGETARCH}" >&2; exit 1 ;; \
  esac && \
  if ! command -v bzip2 >/dev/null 2>&1; then \
    apt-get update && \
    apt-get install -y --no-install-recommends bzip2 && \
    rm -rf /var/lib/apt/lists/*; \
  fi && \
  curl -fsSL -o /tmp/monero.tar.bz2 \
    "https://downloads.getmonero.org/cli/monero-${monero_arch}-v${VERSION}.tar.bz2" && \
  echo "${monero_sha}  /tmp/monero.tar.bz2" | sha256sum -c - && \
  mkdir -p /app/monero && \
  tar -xjf /tmp/monero.tar.bz2 -C /app/monero --strip-components=1 && \
  rm -f /tmp/monero.tar.bz2 && \
  /app/monero/monerod --version && \
  if [ -f /app/monero/LICENSE ]; then \
    install -D -m 0644 /app/monero/LICENSE /usr/share/licenses/monero-node/LICENSE; \
  fi && \
  chown -R apps:apps /app/monero && \
  chmod -R 755 /app/monero

USER apps
COPY --chmod=0755 . /

EXPOSE 18080 18089

VOLUME /config
