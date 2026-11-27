# Build stage: produce the bridge CLI binaries for the target architecture
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454 AS build

ARG VERSION
ARG TARGETARCH

USER root
WORKDIR /tmp/build

ENV GOCACHE=/tmp/go-cache \
    GOPATH=/tmp/go \
    GOMODCACHE=/tmp/go/pkg/mod

# UNVERIFIED: the golang version packaged for ubuntu 26.04 must satisfy the go.mod of proton-bridge v${VERSION}
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        git \
        gnupg \
        golang \
        libsecret-1-dev \
        make && \
    rm -rf /var/lib/apt/lists/*

# amd64: verify the vendor .deb signature and unpack it (no GUI libraries are installed)
# arm64: no prebuilt asset, so build from the tagged source
# UNVERIFIED: output paths inside the .deb and the Makefile targets (upstream image uses bridge, proton-bridge, vault-editor)
RUN set -eux; \
    mkdir -p /tmp/build/out; \
    curl -fsSL -o /tmp/build/LICENSE "https://raw.githubusercontent.com/ProtonMail/proton-bridge/v${VERSION}/LICENSE"; \
    if [ "${TARGETARCH}" = "amd64" ]; then \
      base="https://github.com/ProtonMail/proton-bridge/releases/download/v${VERSION}"; \
      deb="protonmail-bridge_${VERSION}-1_amd64.deb"; \
      curl -fsSL -o /tmp/build/bridge.deb "${base}/${deb}"; \
      curl -fsSL -o /tmp/build/bridge.deb.sig "${base}/${deb}.sig"; \
      curl -fsSL -o /tmp/build/bridge_pubkey.gpg "${base}/bridge_pubkey.gpg"; \
      export GNUPGHOME="$(mktemp -d)"; \
      gpg --batch --import /tmp/build/bridge_pubkey.gpg; \
      gpg --batch --verify /tmp/build/bridge.deb.sig /tmp/build/bridge.deb; \
      dpkg-deb -x /tmp/build/bridge.deb /tmp/build/deb; \
      find /tmp/build/deb -type f \( -name bridge -o -name proton-bridge \) -exec install -m 0755 {} /tmp/build/out/ \; ; \
    else \
      git clone --depth 1 --branch "v${VERSION}" https://github.com/ProtonMail/proton-bridge.git /tmp/build/src; \
      make -C /tmp/build/src build-nogui; \
      make -C /tmp/build/src vault-editor; \
      find /tmp/build/src -maxdepth 3 -type f \( -name bridge -o -name proton-bridge -o -name vault-editor \) -perm -u+x -exec install -m 0755 {} /tmp/build/out/ \; ; \
    fi; \
    rm -rf /tmp/build/deb /tmp/build/src /tmp/go-cache /tmp/go

# Final stage: runtime with the keychain tools the bridge needs
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

USER root

# UNVERIFIED: the package list follows upstream shenxn/protonmail-bridge-docker; socat is needed only if the bridge binds to localhost
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        gnupg \
        libsecret-1-0 \
        pass \
        socat && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /app/protonmail-bridge /usr/share/licenses/protonmail-bridge
COPY --from=build /tmp/build/out/ /app/protonmail-bridge/
COPY --from=build /tmp/build/LICENSE /usr/share/licenses/protonmail-bridge/LICENSE
RUN chmod -R 755 /app/protonmail-bridge

# Keychain and bridge state live under /config
ENV HOME=/config \
    GNUPGHOME=/config/.gnupg \
    PASSWORD_STORE_DIR=/config/.password-store

USER apps
COPY --chmod=0755 . /

# No EXPOSE yet: the bridge listen ports are UNVERIFIED (see settings.yaml)
VOLUME /config
