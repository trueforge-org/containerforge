

FROM ghcr.io/trueforge-org/golang:1.26.0@sha256:ecb4c82c8be78165ae38c3c7bc1b0e7f5c65255ad79d2b0aa2c83d2084a8424a as builder
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

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:5348eb7725294e8090c15b7b495e517f82f4b31497d3bb9de71bbe37476e7454

USER apps:apps

COPY --from=builder /caddy-bin "/app/caddy"
COPY . /

EXPOSE 8080 8443
WORKDIR /config
