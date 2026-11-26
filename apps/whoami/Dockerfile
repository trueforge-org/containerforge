FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS builder

ARG VERSION

USER root
RUN git clone --depth 1 --branch "${VERSION}" https://github.com/traefik/whoami.git /src/whoami && \
    cd /src/whoami && \
    CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o /usr/local/bin/whoami .

FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

COPY --from=builder /usr/local/bin/whoami /usr/local/bin/whoami

# Upstream defaults to port 80, which needs privileges this image does not have
ENV WHOAMI_PORT_NUMBER=8080

EXPOSE 8080/tcp

USER apps
COPY --chmod=0755 . /
ENTRYPOINT ["/usr/local/bin/whoami"]
