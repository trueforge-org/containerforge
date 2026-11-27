FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
USER root
WORKDIR /app

# Outpost binary from the release tag version/${VERSION}. The release has no per-asset checksum file.
# TODO: pin a SHA-256 per arch after one manual download and record it in the PR. No value is pinned yet.
# UNVERIFIED: metadata.json content, and whether the binary needs glibc symbols the ubuntu base lacks (upstream uses CGO).
RUN set -eux; \
  case "${TARGETARCH}" in \
    amd64) ARCH=amd64 ;; \
    arm64) ARCH=arm64 ;; \
    *) echo "unsupported arch ${TARGETARCH}" >&2; exit 1 ;; \
  esac; \
  mkdir -p /app /usr/share/licenses/authentik-ldap; \
  curl -fsSL -o /tmp/authentik-ldap \
    "https://github.com/goauthentik/authentik/releases/download/version/${VERSION}/authentik-outpost-ldap_linux_${ARCH}"; \
  install -m 0755 /tmp/authentik-ldap /app/ldap; \
  rm -f /tmp/authentik-ldap

# UNVERIFIED: the LICENSE path at this tag. The default branch is not used.
RUN set -eux; \
  curl -fsSL -o /usr/share/licenses/authentik-ldap/LICENSE \
    "https://raw.githubusercontent.com/goauthentik/authentik/version/${VERSION}/LICENSE"; \
  chmod -R 755 /app; \
  rm -rf /tmp/*

ENV TMPDIR=/tmp

USER apps
COPY --chmod=0755 . /

EXPOSE 3389 6636 9300
VOLUME /config
WORKDIR /app
