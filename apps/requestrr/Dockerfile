

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:3b826c0233182d7c31a9323121178b98976765b9ee03f9a96200ab0c70e2e1e2
ARG TARGETARCH
ARG VENDOR
ARG VERSION


ARG TARGETARCH=${TARGETARCH/arm64/arm64}
ARG TARGETARCH=${TARGETARCH/amd64/x64}

ENV WEBUI_PORTS="4545/tcp,4545/udp"

USER root
WORKDIR /app

RUN mkdir "/app/bin" && \
    curl -fsSL "https://github.com/thomst08/requestrr/releases/download/V${VERSION}/requestrr-linux-${TARGETARCH}.tar.gz" | tar xzf - -C "/app/bin" --strip-components=1 && \
    chmod -R u=rwX,go=rX "/app" && \
    chown -R apps:apps "/app"

COPY . /

EXPOSE 4545

USER apps:apps
WORKDIR /config
