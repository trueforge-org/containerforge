

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:aba163fade18b21ae0132813e7522fbd005a1cdc8818e308679480a78ba93bb9
ARG TARGETARCH
ARG VENDOR
ARG VERSION

USER root
WORKDIR /app

RUN curl -fsSL "https://github.com/stashapp/stash/releases/download/v${VERSION}/stash-linux" > "/app/stash" && \
    chmod 755 "/app/stash"

ARG DEBIAN_FRONTEND="noninteractive"

#
# ------------------------------------------------------------
#  ALL UBUNTU APT-GET STEPS (ONE RUN)
# ------------------------------------------------------------
#
RUN apt-get update && \
    apt-get install -y --no-install-recommends --no-install-suggests gnupg curl ca-certificates && \
    curl -fsSL "https://repo.jellyfin.org/ubuntu/jellyfin_team.gpg.key" | apt-key add - && \
    echo "deb [arch=amd64] https://repo.jellyfin.org/ubuntu noble main" > /etc/apt/sources.list.d/jellyfin.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends --no-install-suggests \
        ocl-icd-libopencl1 \
        libvips-tools \
        python3-pip \
        jellyfin-ffmpeg7 && \
    apt-get purge -y gnupg && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

#
# ------------------------------------------------------------
#  Python packages
# ------------------------------------------------------------
#
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

#
# ------------------------------------------------------------
#  FFmpeg symlinks
# ------------------------------------------------------------
#
RUN ln -s /usr/lib/jellyfin-ffmpeg/ffmpeg /usr/bin/ffmpeg && \
    ln -s /usr/lib/jellyfin-ffmpeg/ffprobe /usr/bin/ffprobe && \
    ln -s /usr/lib/jellyfin-ffmpeg/vainfo /usr/bin/vainfo

#
# ------------------------------------------------------------
#  Intel compute runtime
# ------------------------------------------------------------
#
ARG INTEL_CR_VERSION
RUN mkdir /tmp/intel-compute-runtime && \
    cd /tmp/intel-compute-runtime && \
    curl -fsSL "https://api.github.com/repos/intel/compute-runtime/releases/tags/${INTEL_CR_VERSION}" | jq -r '.assets[].browser_download_url' | grep -e "libigdgmm.*\.deb" >> list.txt && \
    curl -fsSL "https://api.github.com/repos/intel/compute-runtime/releases/tags/${INTEL_CR_VERSION}" | jq -r '.assets[].browser_download_url' | grep -e "intel-opencl-icd.*\.deb" >> list.txt && \
    curl -fsSL "https://api.github.com/repos/intel/compute-runtime/releases/tags/${INTEL_CR_VERSION}" | jq -r '.body' | grep "wget" | grep "intel-graphics-compiler" | sed 's|wget ||g' >> list.txt && \
    echo "https://github.com/intel/compute-runtime/releases/download/24.35.30872.22/intel-opencl-icd-legacy1_24.35.30872.22_amd64.deb" >> list.txt && \
    echo "https://github.com/intel/intel-graphics-compiler/releases/download/igc-1.0.17537.20/intel-igc-core_1.0.17537.20_amd64.deb" >> list.txt && \
    echo "https://github.com/intel/intel-graphics-compiler/releases/download/igc-1.0.17537.20/intel-igc-opencl_1.0.17537.20_amd64.deb" >> list.txt && \
    wget -i list.txt && \
    dpkg -i *.deb || apt-get -f install -y && \
    cd .. && \
    rm -rf /tmp/*

COPY . /

USER apps:apps
WORKDIR /config
