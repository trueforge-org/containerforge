# Initial draft from plan.md. UNVERIFIED items are marked inline.
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454
ARG VERSION
ARG TARGETARCH
USER root

# Media tools for thumbnails and metadata. Package names other than ffmpeg are UNVERIFIED on 26.04.
# LibreOffice, aria2 and supervisor from the upstream image are not included (plan section 10).
RUN apt-get update && apt-get install -y --no-install-recommends \
        ffmpeg \
        fonts-noto-core \
        libheif1 \
        libraw-bin \
        libvips-tools \
    && rm -rf /var/lib/apt/lists/*

# Verify the archive against the release checksums.txt asset (line format assumed "<hash>  <file>", UNVERIFIED).
RUN set -eux; \
    cd /tmp; \
    curl -fsSLO "https://github.com/cloudreve/cloudreve/releases/download/${VERSION}/cloudreve_${VERSION}_linux_${TARGETARCH}.tar.gz"; \
    curl -fsSLO "https://github.com/cloudreve/cloudreve/releases/download/${VERSION}/checksums.txt"; \
    grep " cloudreve_${VERSION}_linux_${TARGETARCH}.tar.gz\$" checksums.txt | sha256sum -c -; \
    mkdir -p /tmp/cr; \
    tar xzf "cloudreve_${VERSION}_linux_${TARGETARCH}.tar.gz" -C /tmp/cr; \
    install -D -m 0755 /tmp/cr/cloudreve /app/cloudreve; \
    install -D -m 0644 /tmp/cr/LICENSE /usr/share/licenses/cloudreve/LICENSE; \
    rm -rf /tmp/*

ENV HOME=/config \
    CR_SETTING_DEFAULT_thumb_ffmpeg_enabled=1 \
    CR_SETTING_DEFAULT_thumb_vips_enabled=1 \
    CR_SETTING_DEFAULT_media_meta_ffprobe=1 \
    CR_SETTING_DEFAULT_thumb_libraw_enabled=1

USER apps
COPY --chmod=0755 . /

WORKDIR /config
EXPOSE 5212
VOLUME /config
