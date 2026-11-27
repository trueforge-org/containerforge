FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
USER root

ENV \
  HOME=/tmp \
  SP_DB_TYPE=sqlite \
  SP_DB_DIR=/config \
  SP_FILESTORAGE_LOCAL_ROOT=/config/files

RUN echo "*** Installing SolidPing ***" && \
  case "${TARGETARCH}" in \
    amd64) SP_SHA256=1f5e661e29000105c2c6c993fe964674b2670f976bf472f5a06ac595c8901f33 ;; \
    arm64) SP_SHA256=94524f93772d43515162f6c72a4e72819df832ac75d7c3b48c44a3924c05da39 ;; \
    *) echo "unsupported arch: ${TARGETARCH}" >&2; exit 1 ;; \
  esac && \
  curl -fsSL --proto '=https' -o \
    /tmp/solidping.gz \
    "https://github.com/fclairamb/solidping/releases/download/v${VERSION}/solidping-linux-${TARGETARCH}.gz" && \
  echo "${SP_SHA256}  /tmp/solidping.gz" | sha256sum -c - && \
  mkdir -p /app/solidping && \
  gunzip -c /tmp/solidping.gz > /app/solidping/solidping && \
  chmod 0755 /app/solidping/solidping && \
  echo "*** Installing license ***" && \
  mkdir -p /usr/share/licenses/solidping && \
  curl -fsSL --proto '=https' -o \
    /usr/share/licenses/solidping/LICENSE \
    "https://raw.githubusercontent.com/fclairamb/solidping/v${VERSION}/LICENSE" && \
  chown -R apps:apps /app && chmod -R 755 /app && \
  echo "*** Cleaning Up ***" && \
  rm -f /tmp/solidping.gz

USER apps
COPY --chmod=0755 . /

EXPOSE 4000

VOLUME /config
