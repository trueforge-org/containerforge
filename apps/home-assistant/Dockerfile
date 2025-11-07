# syntax=docker/dockerfile:1

FROM ghcr.io/trueforge-org/python:3.13.7@sha256:462920f87d68208b7203ce499c21a3848dbf1ff90e726538027b40c414bd7ff9
ARG TARGETARCH
ARG TARGETARCH=${TARGETARCH/arm64/aarch64}
ARG TARGETARCH=${TARGETARCH/arm64/aarch64}
ARG VERSION

ENV HOME="/config" \
    PYTHONUSERBASE="/usr/local" \
    VENV_FOLDER="/config/.venv"

USER root
WORKDIR /app

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install runtime and build dependencies
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        binutils \
        bluez \
        bluez-cups \
        cups \
        udev \
        ffmpeg \
        git \
        hwdata \
        libimlib2 \
        iperf3 \
        iputils-ping \
        libcap2 \
        libftdi1 \
        libgpiod2 \
        libturbojpeg0-dev \
        libpulse0 \
        libstdc++6 \
        libxslt1.1 \
        libzbar0 \
        mailcap \
        libmariadb3 \
        net-tools \
        nmap \
        openssh-client \
        openssl \
        pianobar \
        libpq5 \
        pulseaudio \
        socat \
        libtiff6 \
        unzip \
        build-essential \
        default-libmysqlclient-dev \
        libpq-dev \
        pkg-config \
        autoconf \
        build-essential \
        libffi-dev \
        && rm -rf /var/lib/apt/lists/*

# Install Python packages and Home Assistant
RUN pip install uv; \
    uv pip install --index-strategy unsafe-best-match \
        --requirement "https://raw.githubusercontent.com/home-assistant/core/refs/tags/${VERSION}/requirements.txt"; \
    uv pip install --index-strategy unsafe-best-match --requirement "https://raw.githubusercontent.com/home-assistant/core/refs/tags/${VERSION}/requirements_all.txt"; \
    uv pip install --index-strategy unsafe-best-match homeassistant=="${VERSION}"; \
    curl -fsSL -o /bin/go2rtc "https://github.com/AlexxIT/go2rtc/releases/latest/download/go2rtc_linux_${TARGETARCH}"; \
    chmod +x /bin/go2rtc; \
    mkdir -p /config && chown nobody:nogroup -R /config; \
    rm -rf /root/.cache /tmp/*

USER apps:apps
COPY --chmod=0775 . /

WORKDIR /config
VOLUME ["/config"]

CMD []
