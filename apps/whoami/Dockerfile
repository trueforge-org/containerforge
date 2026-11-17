FROM ghcr.io/trueforge-org/golang:1.27.4@sha256:00f64ec10e368246f73dd85badaeb4935861ccebe80107f0681914ae7f62a033 AS builder

ARG VERSION

USER root
RUN git clone --depth 1 --branch "${VERSION}" https://github.com/traefik/whoami.git /src/whoami && \
    cd /src/whoami && \
    CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o /usr/local/bin/whoami .

FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:5b73e70bff124668c9432d50ac6bcdfb961c11e82debe5004aa68895feab0238

COPY --from=builder /usr/local/bin/whoami /usr/local/bin/whoami

# Upstream defaults to port 80, which needs privileges this image does not have
ENV WHOAMI_PORT_NUMBER=8080

EXPOSE 8080/tcp

USER apps
COPY --chmod=0755 . /
ENTRYPOINT ["/usr/local/bin/whoami"]
