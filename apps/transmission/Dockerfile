

FROM ghcr.io/trueforge-org/python:3.13.12@sha256:d9b5d12c8e22d9b84df211da15c73e7e2b36441675f00bba2c706f93526c602b
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
COPY --from=ghcr.io/linuxserver/unrar:latest@sha256:92b4d32099ca9c9290bed83b4ba7cad5b0f563fd3e3bc63ca6a924b6f8a9245b /usr/bin/unrar-ubuntu /usr/bin/unrar

USER apps
WORKDIR /config
