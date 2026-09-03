

FROM ghcr.io/trueforge-org/golang:1.27.1@sha256:b068d80b5f6d257316b4f66ac5b2099f8ebbcd780855da5e80e4bccb3e9b18d8 as builder
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

FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:24efb13c405c262ba2d501640e0a70e0454439ed722125055b11814ff49323db

USER apps

COPY --from=builder /caddy-bin "/app/caddy"
COPY --chmod=0755 . /

EXPOSE 8080 8443
WORKDIR /config
