# build stage: static Go binary. BLOCKER: upstream targets dns.hetzner.com, shut down May 2026 (see plan.md section 10).
FROM --platform=$BUILDPLATFORM golang:1.26@sha256:6e59e17a20f13c102e49d82dffab66d41cffe6c266b225d82794328aea859ab5 AS build

# VERSION is the upstream commit SHA (no release tags are usable)
ARG VERSION
ARG TARGETARCH
ENV GOCACHE=/tmp/go-cache \
    GOPATH=/tmp/go \
    CGO_ENABLED=0

WORKDIR /src

RUN \
  mkdir -p \
    /tmp/go-cache \
    /out && \
  curl -fL -o \
    /tmp/hetzner-ddns.tar.gz \
    "https://github.com/kutzilla/docker-hetzner-ddns/archive/${VERSION}.tar.gz" && \
  tar xf \
    /tmp/hetzner-ddns.tar.gz -C \
    /src --strip-components=1 && \
  rm -f /tmp/hetzner-ddns.tar.gz && \
  GOOS=linux GOARCH="${TARGETARCH}" \
    go build -trimpath -ldflags="-s -w" -o /out/hetzner-ddns ./cmd/hetzner-ddns && \
  cp /src/LICENSE.md /out/LICENSE.md

# runtime stage
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

# set version label
ARG VERSION
USER root

COPY --from=build /out/hetzner-ddns /app/hetzner-ddns
COPY --from=build /out/LICENSE.md /usr/share/licenses/hetzner-ddns/LICENSE.md

RUN \
  echo "**** prepare paths ****" && \
  chown -R root:root /app && \
  chmod -R 0755 /app

ENV HOME=/tmp

# copy local files
USER apps
COPY --chmod=0755 . /

# no ports; no state is stored, the volume is declared for sibling consistency
VOLUME /config

WORKDIR /config

CMD ["/start.sh"]
