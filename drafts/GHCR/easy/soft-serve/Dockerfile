FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
USER root

ENV \
  HOME=/tmp \
  CI=1 \
  SOFT_SERVE_DATA_PATH=/config/soft-serve

# Unresolved: apt package versions (git, bash, openssh-client) are not pinned.
RUN echo "*** Installing runtime dependencies ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    git \
    bash \
    openssh-client && \
  echo "*** Installing Soft Serve ***" && \
  case "${TARGETARCH}" in \
    amd64) ARCH="x86_64" ;; \
    arm64) ARCH="arm64" ;; \
    *) echo "Unsupported architecture: ${TARGETARCH}" >&2; exit 1 ;; \
  esac && \
  FILE="soft-serve_${VERSION}_Linux_${ARCH}.tar.gz" && \
  mkdir -p /tmp/soft /app/soft-serve /usr/share/licenses/soft-serve && \
  curl -fL -o "/tmp/${FILE}" \
    "https://github.com/charmbracelet/soft-serve/releases/download/v${VERSION}/${FILE}" && \
  curl -fL -o /tmp/checksums.txt \
    "https://github.com/charmbracelet/soft-serve/releases/download/v${VERSION}/checksums.txt" && \
  echo "*** Verifying checksum ***" && \
  (cd /tmp && grep " ${FILE}\$" checksums.txt | sha256sum -c -) && \
  tar xzf "/tmp/${FILE}" -C /tmp/soft --strip-components=1 && \
  install -m 0755 /tmp/soft/soft /app/soft-serve/soft && \
  install -m 0644 /tmp/soft/LICENSE /usr/share/licenses/soft-serve/LICENSE && \
  chown -R apps:apps /app && \
  echo "*** Cleaning Up ***" && \
  rm -rf /tmp/soft "/tmp/${FILE}" /tmp/checksums.txt /var/lib/apt/lists/*

USER apps
COPY --chmod=0755 . /

EXPOSE 23231 23232 23233 9418

VOLUME /config
