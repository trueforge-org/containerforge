

FROM ghcr.io/trueforge-org/golang:1.27.4@sha256:f4cc132caaec56625d0bffc7254681716fed8645575fb59fbc5799a400c04d15 as builder
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

FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:cdc35c1e179c9ebb98d18ad2f3c3b5ff340fbda5e75ccbd4f022ef7da5885760

USER apps

COPY --from=builder /caddy-bin "/app/caddy"
COPY --chmod=0755 . /

EXPOSE 8080 8443
WORKDIR /config
