

FROM ghcr.io/trueforge-org/golang:1.26.7@sha256:c215e30870e6f8535aeecdec1a82d24609846b254a023a3dce8d3801b68ccb95 as builder
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

FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:bc182517d87eb71b9a71e11941223716611ebe6002864b1a28d03cca78fa5a35

USER apps

COPY --from=builder /caddy-bin "/app/caddy"
COPY --chmod=0755 . /

EXPOSE 8080 8443
WORKDIR /config
