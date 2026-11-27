FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
# Not renovated: GitHub publishes a SHA-256 digest per release asset. Update both with every VERSION bump.
ARG SHA256_AMD64=b0a27c536351010fd1ba90ce4930ff980f187ad015d9287c4731f9c109334dbe
ARG SHA256_ARM64=d0a17af0cda75676f9a2d1378636562d01a2b5bb8ddc4fa34be87477525caa4d
USER root

ENV \
  HOME=/config

RUN echo "*** Installing GLAuth ***" && \
  case "${TARGETARCH}" in \
    amd64) sha="${SHA256_AMD64}" ;; \
    arm64) sha="${SHA256_ARM64}" ;; \
    *) echo "unsupported arch ${TARGETARCH}" >&2; exit 1 ;; \
  esac && \
  mkdir -p /usr/share/licenses/glauth && \
  curl -fsSL -o /app/glauth \
    "https://github.com/glauth/glauth/releases/download/GLAuth-v${VERSION}/glauth-linux-${TARGETARCH}" && \
  echo "${sha}  /app/glauth" | sha256sum -c - && \
  curl -fsSL -o /usr/share/licenses/glauth/LICENSE \
    "https://raw.githubusercontent.com/glauth/glauth/GLAuth-v${VERSION}/LICENSE" && \
  chown -R apps:apps /app && chmod -R 755 /app

USER apps
COPY --chmod=0755 . /

EXPOSE 3893 5555

VOLUME /config
