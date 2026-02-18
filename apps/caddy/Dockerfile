

FROM ghcr.io/trueforge-org/golang:1.26.0@sha256:74ea31a8f0af085d1bf920c5b10b75349effddab995cc4c2e2cc401a93b16839 as builder
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

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:a42a7b2fe3c044339769eca34c011337ec5ecdbb7ff3c2af30bc9105afb035b8

USER apps

COPY --from=builder /caddy-bin "/app/caddy"
COPY . /

EXPOSE 8080 8443
WORKDIR /config
