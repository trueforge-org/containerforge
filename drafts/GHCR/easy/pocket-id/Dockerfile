FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
USER root

ENV \
  APP_ENV=production \
  HOME=/config \
  PORT=1411 \
  HOST=0.0.0.0

RUN echo "*** Installing Pocket ID ***" && \
  mkdir -p /app /usr/share/licenses/pocket-id && \
  curl -fL -o /tmp/pocket-id \
    "https://github.com/pocket-id/pocket-id/releases/download/v${VERSION}/pocket-id_linux_${TARGETARCH}" && \
  curl -fL -o /tmp/checksums.txt \
    "https://github.com/pocket-id/pocket-id/releases/download/v${VERSION}/checksums.txt" && \
  echo "*** Verifying checksum ***" && \
  (cd /tmp && grep " pocket-id_linux_${TARGETARCH}\$" checksums.txt | sed "s# pocket-id_linux_${TARGETARCH}\$# pocket-id#" | sha256sum -c -) && \
  install -m 0755 /tmp/pocket-id /app/pocket-id && \
  curl -fL -o /usr/share/licenses/pocket-id/LICENSE \
    "https://raw.githubusercontent.com/pocket-id/pocket-id/v${VERSION}/LICENSE" && \
  chown -R apps:apps /app && \
  echo "*** Cleaning Up ***" && \
  rm -f /tmp/pocket-id /tmp/checksums.txt

USER apps
COPY --chmod=0755 . /

EXPOSE 1411

VOLUME /config
