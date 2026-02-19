

FROM ghcr.io/trueforge-org/python:3.13.12@sha256:cac0b51ee72888e75bf2ff4ae1a46be0b5310663584fc54d621d0476e573f5b8
ARG TARGETARCH
ARG TARGETARCH=${TARGETARCH/arm64/aarch64}
ARG TARGETARCH=${TARGETARCH/arm64/aarch64}
ARG VERSION

ENV HOME="/config" \
    PYTHONUSERBASE="/usr/local"

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
RUN pip3 install --no-cache-dir psycopg2; \
    pip3 install --no-cache-dir --find-links https://wheel-index.linuxserver.io/ubuntu/ \
        --requirement "https://raw.githubusercontent.com/home-assistant/core/refs/tags/${VERSION}/requirements.txt"; \
    pip3 install --no-cache-dir --find-links https://wheel-index.linuxserver.io/ubuntu/ \
        --requirement "https://raw.githubusercontent.com/home-assistant/core/refs/tags/${VERSION}/requirements_all.txt"; \
    pip3 install --no-cache-dir --find-links https://wheel-index.linuxserver.io/ubuntu/ homeassistant=="${VERSION}"; \
    cp /etc/ssl/certs/ca-certificates.crt /etc/ca-certificates.crt; \
    chmod 644 /etc/ca-certificates.crt; \
    curl -fsSL -o /bin/go2rtc "https://github.com/AlexxIT/go2rtc/releases/latest/download/go2rtc_linux_${TARGETARCH}"; \
    chmod +x /bin/go2rtc; \
    mkdir -p /config && chown 568:568 -R /config; \
    rm -rf /root/.cache /tmp/*

COPY container-test.yaml /container-test.yaml
USER apps
COPY --chmod=0775 . /

WORKDIR /config
VOLUME ["/config"]

CMD []
