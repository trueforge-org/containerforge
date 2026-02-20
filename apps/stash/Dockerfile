FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:e5507376cb59a4669ad6179bc43e081b150558c96ab8e06b558e3b62c71241c8

ARG TARGETARCH
ARG VERSION
ARG INTEL_CR_VERSION

USER root
WORKDIR /app

# -----------------------------
# Download Stash binary per architecture
# -----------------------------
RUN if [ "$TARGETARCH" = "amd64" ]; then \
        STASH_URL="https://github.com/stashapp/stash/releases/download/v${VERSION}/stash-linux"; \
    else \
        STASH_URL="https://github.com/stashapp/stash/releases/download/v${VERSION}/stash-linux-arm64v8"; \
    fi && \
    curl -fsSL "$STASH_URL" -o /app/stash && \
    chmod 755 /app/stash

# -----------------------------
# Install system packages
# -----------------------------
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get install -y --no-install-recommends gnupg curl ca-certificates jq wget python3-pip libvips-tools && \
    \
    curl -fsSL https://repo.jellyfin.org/ubuntu/jellyfin_team.gpg.key | apt-key add - && \
    echo "deb [arch=$TARGETARCH] https://repo.jellyfin.org/ubuntu noble main" > /etc/apt/sources.list.d/jellyfin.list && \
    apt-get update && \
    \
    # Install ffmpeg package
    if [ "$TARGETARCH" = "amd64" ]; then \
        apt-get install -y --no-install-recommends jellyfin-ffmpeg7 ocl-icd-libopencl1; \
    else \
        apt-get install -y --no-install-recommends jellyfin-ffmpeg7; \
    fi

# -----------------------------
# Install Python packages
# -----------------------------
RUN pip3 install --break-system-packages --no-cache-dir --upgrade \
        bs4 \
        cloudscraper \
        fastbencode \
        lxml \
        mechanicalsoup \
        pystashlib \
        requests \
        requests-toolbelt \
        stashapp-tools

# -----------------------------
# FFmpeg symlinks
# -----------------------------
RUN ln -s /usr/lib/jellyfin-ffmpeg/ffmpeg /usr/bin/ffmpeg && \
    ln -s /usr/lib/jellyfin-ffmpeg/ffprobe /usr/bin/ffprobe && \
    ln -s /usr/lib/jellyfin-ffmpeg/vainfo /usr/bin/vainfo

# -----------------------------
# Intel Compute Runtime (x86 only)
# -----------------------------
RUN if [ "$TARGETARCH" = "amd64" ]; then \
        mkdir /tmp/intel-compute-runtime && cd /tmp/intel-compute-runtime && \
        curl -fsSL "https://api.github.com/repos/intel/compute-runtime/releases/tags/${INTEL_CR_VERSION}" | jq -r '.assets[].browser_download_url' | grep -e "libigdgmm.*\.deb" >> list.txt && \
        curl -fsSL "https://api.github.com/repos/intel/compute-runtime/releases/tags/${INTEL_CR_VERSION}" | jq -r '.assets[].browser_download_url' | grep -e "intel-opencl-icd.*\.deb" >> list.txt && \
        wget -i list.txt && \
        dpkg -i *.deb || apt-get -f install -y && \
        cd .. && rm -rf /tmp/*; \
    fi

# -----------------------------
# Cleanup
# -----------------------------
RUN apt-get purge -y gnupg && apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/*


USER apps
COPY --chmod=0755 . /
WORKDIR /config
