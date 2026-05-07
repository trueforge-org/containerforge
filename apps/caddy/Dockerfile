

FROM ghcr.io/trueforge-org/golang:1.26.2@sha256:0cc15407a61022147e4025d6707343990c17f3e4026ea4c847e07ed8df165ea4 as builder
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

FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:17312da6b52fe7ab6e3bdc8e4a1f99df63c2494b2bad4f4b634a9065d585898e

USER apps

COPY --from=builder /caddy-bin "/app/caddy"
COPY --chmod=0755 . /

EXPOSE 8080 8443
WORKDIR /config
