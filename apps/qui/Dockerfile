

FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:17312da6b52fe7ab6e3bdc8e4a1f99df63c2494b2bad4f4b634a9065d585898e
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
