

FROM ghcr.io/trueforge-org/golang:1.25.1@sha256:be0a42e1af759466bd249b5ce04c288e8beab4df14ac634fc9aa6db04bbe8b03 as builder
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

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:3b826c0233182d7c31a9323121178b98976765b9ee03f9a96200ab0c70e2e1e2

USER apps:apps

COPY --from=builder /caddy-bin "/app/caddy"
COPY . /

EXPOSE 8080 8443
WORKDIR /config
