

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:3b826c0233182d7c31a9323121178b98976765b9ee03f9a96200ab0c70e2e1e2
ARG TARGETARCH
ARG VERSION

ENV    NVIDIA_DRIVER_CAPABILITIES="compute,video,utility"

USER root

RUN \
    curl -fsSL -o /tmp/emby.deb \
        "https://github.com/MediaBrowser/Emby.Releases/releases/download/${VERSION}/emby-server-deb_${VERSION}_${TARGETARCH}.deb" \
    && \
    mkdir -p /app/bin /tmp/emby \
    && dpkg-deb -xv /tmp/emby.deb /tmp/emby/ \
    && mv -t /app/bin/ /tmp/emby/opt/emby-server/* \
    && chown -R root:root /app && chmod -R 755 /app \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY . /

USER apps:apps
WORKDIR /config
