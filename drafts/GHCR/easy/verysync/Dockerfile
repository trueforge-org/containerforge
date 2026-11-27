FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
# UNVERIFIED: a branch name. Replace it with a commit SHA once one is resolved (plan.md section 4). The sha256 checks still protect the download.
ARG VERYSYNC_REF=master
# sha256 of the committed release tarballs, computed locally. Upstream publishes no checksum file for them. Bump together with VERSION.
ARG SHA256_AMD64=8a4b347669cd33def98b3bf1888576c8dc786ed77485080901bba0101c4413bd
ARG SHA256_ARM64=708702fa19c321acb7e1aaa895a6f2cf8cb6189ab8ede6edf5049b61ad1f0ae0

USER root

ENV \
  HOME=/config \
  PORT=8886

RUN echo "*** Installing VeriSync ***" && \
  case "${TARGETARCH}" in \
    amd64) sha256="${SHA256_AMD64}" ;; \
    arm64) sha256="${SHA256_ARM64}" ;; \
    *) echo "Unsupported arch: ${TARGETARCH}" >&2; exit 1 ;; \
  esac && \
  base="verysync-linux-${TARGETARCH}-v${VERSION}" && \
  curl -fsSL -o /tmp/verysync.tar.gz \
    "https://raw.githubusercontent.com/Jonnyan404/verysync/${VERYSYNC_REF}/files/${base}.tar.gz" && \
  echo "${sha256}  /tmp/verysync.tar.gz" | sha256sum -c - && \
  mkdir -p /tmp/verysync-src /app/verysync /usr/share/licenses/verysync && \
  tar -xzf /tmp/verysync.tar.gz -C /tmp/verysync-src && \
  install -m 0755 "/tmp/verysync-src/${base}/verysync" /app/verysync/verysync && \
  curl -fsSL -o /usr/share/licenses/verysync/LICENSE \
    "https://raw.githubusercontent.com/Jonnyan404/verysync/${VERYSYNC_REF}/LICENSE" && \
  chown -R apps:apps /app && chmod -R 755 /app && \
  echo "*** Cleaning Up ***" && \
  rm -rf /tmp/verysync.tar.gz /tmp/verysync-src

USER apps
COPY --chmod=0755 . /

WORKDIR /app/verysync

# UNVERIFIED: port 22330 (data transfer) is listed. Confirm it listens at startup (plan.md section 6).
EXPOSE 8886 22330

VOLUME /config
