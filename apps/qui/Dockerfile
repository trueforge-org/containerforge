

FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:a79e2182efe0bb3d2abd67d2bd445c8c5e2ecd1722ce0a59a678630ab5a4a80d
ARG TARGETARCH
ARG VENDOR
ARG VERSION

ARG TARGETARCH=${TARGETARCH/arm64/arm64}
ARG TARGETARCH=${TARGETARCH/amd64/x86_64}

ENV WEBUI_PORTS="7476/tcp,7476/udp"

USER root
WORKDIR /app

RUN curl -fsSL "https://github.com/autobrr/qui/releases/download/v${VERSION}/qui_${VERSION}_linux_${TARGETARCH}.tar.gz" | tar xzf - -C "/app" --strip-components=0 && \
    chmod -R u=rwX,go=rX "/app" && \
    chmod +x "/app/qui" && \
    chown -R apps:apps "/app"


EXPOSE 7476

USER apps
COPY --chmod=0755 . /
WORKDIR /config
