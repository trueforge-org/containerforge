
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
USER root

ENV \
  HOME=/config \
  TZ=UTC

# Hardware sensor tools in the upstream alpine image (ipmitool, smartmontools, zfs, sysstat) are not included.
# They need privileges, and the feature that uses them is not confirmed (see the PR notes).
RUN echo "*** Installing Notifiarr Client ***" && \
  case "${TARGETARCH}" in \
    amd64) NOTIFIARR_SHA256="705f88ed9c002bc9cc7e429b2377bc563658899a675970902c1511fc035be260" ;; \
    arm64) NOTIFIARR_SHA256="65da3820f42fd57363c4c8d16a4dc65317ebbefbc1deae0322205f096a39430d" ;; \
    *) echo "Unsupported architecture: ${TARGETARCH}" && exit 1 ;; \
  esac && \
  curl -fsSL -o \
    /tmp/notifiarr.linux.gz \
    "https://github.com/Notifiarr/notifiarr/releases/download/${VERSION}/notifiarr.${TARGETARCH}.linux.gz" && \
  echo "${NOTIFIARR_SHA256}  /tmp/notifiarr.linux.gz" | sha256sum -c - && \
  gunzip -c /tmp/notifiarr.linux.gz > /app/notifiarr && \
  chmod 0755 /app/notifiarr && \
  chown apps:apps /app/notifiarr && \
  mkdir -p /usr/share/licenses/notifiarr && \
  curl -fsSL -o \
    /usr/share/licenses/notifiarr/LICENSE \
    "https://raw.githubusercontent.com/Notifiarr/notifiarr/${VERSION}/LICENSE" && \
  echo "*** Cleaning Up ***" && \
  rm -f /tmp/notifiarr.linux.gz

USER apps
COPY --chmod=0755 . /

EXPOSE 5454

VOLUME /config
