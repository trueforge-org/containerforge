

FROM ghcr.io/trueforge-org/golang:1.26.0@sha256:2ba11b36bd37525691b6d9988fe84d59ef36d65a54e0f62b59272dcd67655580 as builder
ARG TARGETARCH
ARG VENDOR
ARG VERSION
ARG XCADDY_VERSION

USER root
WORKDIR /app

RUN wget -O - "https://github.com/caddyserver/xcaddy/releases/download/v${XCADDY_VERSION}/xcaddy_${XCADDY_VERSION}_linux_${TARGETARCH}.tar.gz" | tar xzf - -C "/bin" && \
    xcaddy build v${VERSION} --output /caddy-bin \
        --with github.com/mholt/caddy-ratelimit \
        --with github.com/caddy-dns/cloudflare && \
    chmod 755 "/caddy-bin"

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:5d05227fca161b90936494534d014201795165beb84d5f1aced98565f7c6655e

USER apps:apps

COPY --from=builder /caddy-bin "/app/caddy"
COPY . /

EXPOSE 8080 8443
WORKDIR /config
