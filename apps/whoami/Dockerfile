FROM ghcr.io/trueforge-org/golang:1.27.4@sha256:f4cc132caaec56625d0bffc7254681716fed8645575fb59fbc5799a400c04d15 AS builder

ARG VERSION

USER root
RUN git clone --depth 1 --branch "${VERSION}" https://github.com/traefik/whoami.git /src/whoami && \
    cd /src/whoami && \
    CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o /usr/local/bin/whoami .

FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:cdc35c1e179c9ebb98d18ad2f3c3b5ff340fbda5e75ccbd4f022ef7da5885760

COPY --from=builder /usr/local/bin/whoami /usr/local/bin/whoami

# Upstream defaults to port 80, which needs privileges this image does not have
ENV WHOAMI_PORT_NUMBER=8080

EXPOSE 8080/tcp

USER apps
COPY --chmod=0755 . /
ENTRYPOINT ["/usr/local/bin/whoami"]
