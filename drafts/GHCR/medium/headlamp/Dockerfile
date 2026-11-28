
# Fetch the prebuilt release tarball for the target arch and verify it against the release digest.
# UNVERIFIED: the tarball layout (resources/headlamp-server, resources/frontend) is not confirmed; check with `tar tzf` in the build.
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS fetch
ARG VERSION
ARG TARGETARCH
ARG SHA256_AMD64=1747c5de63963be925ded64dc2a5308144d260e43452855169bc771f03846434
ARG SHA256_ARM64=f209486c188b386f558aea39a860929f5f65d40d6546043062182a471b048ff3
USER root
RUN echo "*** Fetching Headlamp ${VERSION} (${TARGETARCH}) ***" && \
  case "${TARGETARCH}" in \
    amd64) ARCH=x64; SHA256="${SHA256_AMD64}" ;; \
    arm64) ARCH=arm64; SHA256="${SHA256_ARM64}" ;; \
    *) echo "unsupported arch: ${TARGETARCH}" >&2; exit 1 ;; \
  esac && \
  curl -fL -o /tmp/headlamp.tar.gz \
    "https://github.com/kubernetes-sigs/headlamp/releases/download/${VERSION}/Headlamp-${VERSION#v}-linux-${ARCH}.tar.gz" && \
  echo "${SHA256}  /tmp/headlamp.tar.gz" | sha256sum -c - && \
  mkdir -p /tmp/hl && \
  tar xzf /tmp/headlamp.tar.gz -C /tmp/hl && \
  rm /tmp/headlamp.tar.gz && \
  mkdir -p /usr/share/licenses/headlamp && \
  find /tmp/hl -maxdepth 3 \( -iname 'LICENSE*' -o -iname 'NOTICE*' -o -iname 'THIRD*' \) \
    -exec cp {} /usr/share/licenses/headlamp/ \; && \
  mkdir -p /tmp/out && \
  cp -a /tmp/hl/resources/headlamp-server /tmp/out/ && \
  cp -a /tmp/hl/resources/frontend /tmp/out/ && \
  rm -rf /tmp/hl

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

USER root

COPY --from=fetch --chmod=0755 /tmp/out/headlamp-server /app/headlamp/headlamp-server
COPY --from=fetch /tmp/out/frontend /app/headlamp/frontend
COPY --from=fetch /usr/share/licenses/headlamp /usr/share/licenses/headlamp

RUN chown -R apps:apps /app && \
  chmod -R 755 /app

ENV \
  HOME=/config \
  XDG_CACHE_HOME=/tmp

USER apps
COPY --chmod=0755 . /

EXPOSE 4466

VOLUME /config

WORKDIR /app/headlamp
