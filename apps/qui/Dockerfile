

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:4199c1486b3e46e0d990afe382130d196c0aae8b76948bc73997b46e44b0caba
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

COPY . /

EXPOSE 7576

USER apps:apps
WORKDIR /config
