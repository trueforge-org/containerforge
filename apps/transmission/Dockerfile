

FROM ghcr.io/trueforge-org/python:3.13.12@sha256:911cc57981370bafe55e08ba7d6e209d088a6a15f92fceacaee52fcc17226458
ARG TARGETARCH
ARG MINIJINJA_ARCH=${TARGETARCH/arm64/aarch64}
ARG MINIJINJA_ARCH=${MINIJINJA_ARCH/amd64/x86_64}
ARG VERSION

ENV HOME="/config" \
    XDG_CONFIG_HOME="/config" \
    XDG_DATA_HOME="/config" \
    TRANSMISSION_WEB_HOME="/usr/share/transmission/public_html"

USER root
WORKDIR /app

# Install Transmission and minijinja-cli
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        p7zip-full \
        transmission-daemon="${VERSION}" \
        transmission-cli="${VERSION}" \
        transmission-common="${VERSION}" \
    && rm -rf /var/lib/apt/lists/*; \
    \
    # Download minijinja-cli
    curl -fsSL "https://github.com/mitsuhiko/minijinja/releases/download/2.8.0/minijinja-cli-${MINIJINJA_ARCH}-unknown-linux-gnu.tar.xz" \
        | tar xJf - -C /usr/local/bin/ --strip-components=1; \
    rm -rf /tmp/*

# Copy local files
COPY . /

# Copy unrar binary from LinuxServer image
COPY --from=ghcr.io/linuxserver/unrar:latest@sha256:22e6e76f2f2372a7cd6e046b10025e8bde8a04a2b2b2c6072fca6821da5747f7 /usr/bin/unrar-ubuntu /usr/bin/unrar

USER apps
WORKDIR /config
