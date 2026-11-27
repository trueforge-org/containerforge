# UNVERIFIED: the upstream GitHub source is gone (404); the live source is git.mills.io
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454 AS buildstage

ARG VERSION

ENV GOCACHE=/tmp/go-cache \
    GOPATH=/tmp/go

USER root

# UNVERIFIED: Go version in the ubuntu 26.04 archive must support the module's go.mod directive
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      golang-go git ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# UNVERIFIED: tag name 0.0.2 (the plan assumes no "v" prefix); no checksum exists for git tags
RUN git clone --depth 1 --branch "${VERSION}" https://git.mills.io/prologic/static.git /tmp/static \
 && cd /tmp/static \
 && CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o /app/static/static ./cmd/static \
 && rm -rf /tmp/static

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION

USER root

COPY --from=buildstage /app/static/ /app/static/
RUN chmod 0755 /app/static/static

# run as 568
USER apps
COPY --chmod=0755 . /

EXPOSE 8000
WORKDIR /config
VOLUME ["/config"]
CMD ["/start.sh"]
