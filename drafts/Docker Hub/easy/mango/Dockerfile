FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
# Upstream publishes no checksum. Pinned for the amd64 release binary; bump together with VERSION.
ARG MANGO_SHA256_AMD64=e2a90d91927bfbdbe378189fc8342a1dfc186319ebb8196c58db9cc80c11d375
USER root

ENV \
  HOME=/config

# Mango publishes no arm64 binary (only an object file), so this image is amd64 only.
RUN echo "*** Installing Mango ***" && \
  { [ "${TARGETARCH}" = "amd64" ] || { echo "mango publishes no arm64 binary" >&2; exit 1; }; } && \
  curl -fsSL -o /app/mango \
    "https://github.com/getmango/Mango/releases/download/v${VERSION}/mango" && \
  echo "${MANGO_SHA256_AMD64}  /app/mango" | sha256sum -c - && \
  chmod 0755 /app/mango && \
  chown apps:apps /app/mango && \
  mkdir -p /usr/share/licenses/mango && \
  curl -fsSL -o /usr/share/licenses/mango/LICENSE \
    "https://raw.githubusercontent.com/getmango/Mango/v${VERSION}/LICENSE"

USER apps
COPY --chmod=0755 . /

EXPOSE 9000

VOLUME /config
VOLUME /data
