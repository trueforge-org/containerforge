
# UNVERIFIED: no upstream checksum is published for the release tarballs.
# Pinned sha256 values from plan.md (computed 2026-11-23), add per arch if pinning:
#   amd64 d16510d0a7b8b39d387b87883b23d865556d63bb51a6624a4eb3e3732da7e5ef
#   arm64 20265cefc04eb1ec29c27ad1995a2e017e13cc3a461f11e671e476babe54f577
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
USER root

ENV \
  HOME=/config

RUN echo "*** Installing Anki Sync Server ***" && \
  case "${TARGETARCH}" in \
    amd64) A=x64 ;; \
    arm64) A=arm64 ;; \
    *) echo "unsupported arch ${TARGETARCH}" >&2; exit 1 ;; \
  esac && \
  mkdir -p /app /usr/share/licenses/anki-sync-server && \
  curl -fsSL -o \
    /tmp/ankisyncd.tar.gz \
    "https://github.com/ankicommunity/anki-sync-server-rs/releases/download/${VERSION}/ankisyncd_${VERSION}_linux_${A}.tar.gz" && \
  tar xzf \
    /tmp/ankisyncd.tar.gz -C \
    /app/ --strip-components=1 "ankisyncd_${VERSION}_linux_${A}/ankisyncd" && \
  curl -fsSL -o \
    /usr/share/licenses/anki-sync-server/LICENSE \
    "https://raw.githubusercontent.com/ankicommunity/anki-sync-server-rs/${VERSION}/LICENSE" && \
  chown -R root:root /app && \
  chmod 0755 /app/ankisyncd && \
  echo "*** Cleaning Up ***" && \
  rm -f /tmp/ankisyncd.tar.gz

USER apps
COPY --chmod=0755 . /

EXPOSE 27701

WORKDIR /config
VOLUME /config
