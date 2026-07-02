

FROM ghcr.io/trueforge-org/golang:1.26.4@sha256:6dd40678b06a315906c7f1737e157c0d94fd5b48586b7d058daa39fb18f7bf75 as builder
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

FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:a79e2182efe0bb3d2abd67d2bd445c8c5e2ecd1722ce0a59a678630ab5a4a80d

USER apps

COPY --from=builder /caddy-bin "/app/caddy"
COPY --chmod=0755 . /

EXPOSE 8080 8443
WORKDIR /config
