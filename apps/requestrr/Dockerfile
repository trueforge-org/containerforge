

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:cc82810600df75ed627ea3453ff80a6fc5204ea48139834e41f0c74e685ef776
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


EXPOSE 4545

USER apps
COPY --chmod=0755 . /
WORKDIR /config
