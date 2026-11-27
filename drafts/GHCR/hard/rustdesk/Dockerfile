# Initial draft from plan.md. Not built or tested.

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION
ARG TARGETARCH
# UNVERIFIED: no upstream checksum is published. Compute on the first verified download and pin here (self-computed).
ARG SHA256_AMD64=""
ARG SHA256_ARM64=""

USER root

# UNVERIFIED: whether the base already ships curl and unzip (plan section 4, step 4).
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      unzip; \
    rm -rf /var/lib/apt/lists/*

# The arm64 asset is named arm64v8, not arm64.
# UNVERIFIED: zip layout. Patterns match hbbs and hbbr at any depth, flattened with -j.
RUN set -eux; \
    case "${TARGETARCH}" in \
      amd64) asset_arch=amd64; sha="${SHA256_AMD64}" ;; \
      arm64) asset_arch=arm64v8; sha="${SHA256_ARM64}" ;; \
      *) echo "unsupported arch: ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    curl -fL -o /tmp/rustdesk.zip "https://github.com/rustdesk/rustdesk-server/releases/download/${VERSION}/rustdesk-server-linux-${asset_arch}.zip"; \
    echo "${sha}  /tmp/rustdesk.zip" | sha256sum -c -; \
    mkdir -p /app/rustdesk /usr/share/licenses/rustdesk; \
    unzip -j -o /tmp/rustdesk.zip '*hbbs' '*hbbr' -d /app/rustdesk; \
    chmod 0755 /app/rustdesk/hbbs /app/rustdesk/hbbr; \
    curl -fL -o /usr/share/licenses/rustdesk/LICENSE "https://raw.githubusercontent.com/rustdesk/rustdesk-server/${VERSION}/LICENSE"; \
    rm -f /tmp/rustdesk.zip

# Keys and state are written to the working directory, so run from /config (plan section 4).
ENV HOME=/config \
    TMPDIR=/tmp

USER apps
COPY --chmod=0755 . /

EXPOSE 21115 21116 21116/udp 21117 21118 21119

VOLUME /config
WORKDIR /config
