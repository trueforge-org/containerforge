

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:a42a7b2fe3c044339769eca34c011337ec5ecdbb7ff3c2af30bc9105afb035b8
ARG TARGETARCH
ARG VERSION

ENV    NVIDIA_DRIVER_CAPABILITIES="compute,video,utility"

USER root

RUN \
    apt-get update \
    && apt-get install -y --no-install-recommends patchelf \
    && curl -fsSL -o /tmp/emby.deb \
        "https://github.com/MediaBrowser/Emby.Releases/releases/download/${VERSION}/emby-server-deb_${VERSION}_${TARGETARCH}.deb" \
    && \
    mkdir -p /app/bin /tmp/emby \
    && dpkg-deb -xv /tmp/emby.deb /tmp/emby/ \
    && mv -t /app/bin/ /tmp/emby/opt/emby-server/* \
    && if [ "${TARGETARCH}" = "amd64" ]; then \
        patchelf --set-interpreter /app/bin/lib/ld-linux-x86-64.so.2 /app/bin/system/EmbyServer; \
        patchelf --set-interpreter /app/bin/lib/ld-linux-x86-64.so.2 /app/bin/bin/ffmpeg; \
        patchelf --set-interpreter /app/bin/lib/ld-linux-x86-64.so.2 /app/bin/bin/ffdetect; \
        patchelf --set-interpreter /app/bin/lib/ld-linux-x86-64.so.2 /app/bin/bin/ffprobe; \
    elif [ "${TARGETARCH}" = "arm64" ]; then \
        patchelf --set-interpreter /app/bin/lib/ld-linux-aarch64.so.1 /app/bin/system/EmbyServer; \
        patchelf --set-interpreter /app/bin/lib/ld-linux-aarch64.so.1 /app/bin/bin/ffmpeg; \
        patchelf --set-interpreter /app/bin/lib/ld-linux-aarch64.so.1 /app/bin/bin/ffdetect; \
        patchelf --set-interpreter /app/bin/lib/ld-linux-aarch64.so.1 /app/bin/bin/ffprobe; \
    else \
        echo "Error: Unsupported architecture: ${TARGETARCH}"; exit 1; \
    fi \
    && chown -R apps:apps /app && chmod -R 755 /app \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false patchelf \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY . /

COPY container-test.yaml /container-test.yaml
USER apps
WORKDIR /config
