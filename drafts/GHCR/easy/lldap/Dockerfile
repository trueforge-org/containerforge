FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
USER root

ENV \
  HOME=/config

RUN echo "*** Installing lldap ***" && \
  case "${TARGETARCH}" in \
    amd64) LLDAP_ARCH=amd64 ;; \
    arm64) LLDAP_ARCH=aarch64 ;; \
    *) echo "unsupported arch: ${TARGETARCH}" >&2; exit 1 ;; \
  esac && \
  mkdir -p /app && \
  curl -fsSL --proto '=https' -o \
    /tmp/lldap.tar.gz \
    "https://github.com/lldap/lldap/releases/download/v${VERSION}/${LLDAP_ARCH}-lldap.tar.gz" && \
  tar xzf \
    /tmp/lldap.tar.gz -C \
    /app/ --strip-components=1 && \
  echo "*** Installing license ***" && \
  mkdir -p /usr/share/licenses/lldap && \
  curl -fsSL --proto '=https' -o \
    /usr/share/licenses/lldap/LICENSE \
    "https://raw.githubusercontent.com/lldap/lldap/v${VERSION}/LICENSE" && \
  chown -R apps:apps /app && chmod -R 755 /app && \
  echo "*** Cleaning Up ***" && \
  rm -f /tmp/lldap.tar.gz

USER apps
COPY --chmod=0755 . /

EXPOSE 3890 17170

VOLUME /config
