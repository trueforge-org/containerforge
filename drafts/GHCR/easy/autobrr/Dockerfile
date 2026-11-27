FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
# SHA-256 of the release tarballs, from autobrr_<VERSION>_checksums.txt. Update both with VERSION.
ARG SHA256_AMD64=069c886d28c55beac9355c0110e8845edcaa4d43b4edaf6e3cda3f0d8e974947
ARG SHA256_ARM64=bbd1cdb010178db154e0fc88405aa075af1401498adadd37a78970ee0d91ade1

USER root

# Prebuilt static Go binaries from the release tarball (no compile in this image).
# UNVERIFIED: the tarball is expected to ship a LICENSE file; confirm with tar -tzf during the build.
RUN echo "*** Installing autobrr ${VERSION} ***" && \
  case "${TARGETARCH}" in \
    amd64) ASSET_ARCH=x86_64; ASSET_SHA256="${SHA256_AMD64}" ;; \
    arm64) ASSET_ARCH=arm64; ASSET_SHA256="${SHA256_ARM64}" ;; \
    *) echo "Unsupported architecture: ${TARGETARCH}" >&2; exit 1 ;; \
  esac && \
  mkdir -p /tmp/autobrr-dist && \
  curl -fL -o /tmp/autobrr-dist/autobrr.tar.gz \
    "https://github.com/autobrr/autobrr/releases/download/v${VERSION}/autobrr_${VERSION}_linux_${ASSET_ARCH}.tar.gz" && \
  echo "${ASSET_SHA256}  /tmp/autobrr-dist/autobrr.tar.gz" | sha256sum -c - && \
  tar xzf /tmp/autobrr-dist/autobrr.tar.gz -C /tmp/autobrr-dist && \
  install -d /app /usr/share/licenses/autobrr && \
  install -m 0755 /tmp/autobrr-dist/autobrr /tmp/autobrr-dist/autobrrctl /app/ && \
  install -m 0644 /tmp/autobrr-dist/LICENSE /usr/share/licenses/autobrr/LICENSE && \
  chown -R apps:apps /app && chmod -R 755 /app && \
  rm -rf /tmp/autobrr-dist

ENV \
  HOME=/config \
  XDG_CONFIG_HOME=/config \
  XDG_DATA_HOME=/config \
  AUTOBRR__HOST=0.0.0.0 \
  AUTOBRR__PORT=7474

USER apps
COPY --chmod=0755 . /

WORKDIR /app
EXPOSE 7474
VOLUME /config
