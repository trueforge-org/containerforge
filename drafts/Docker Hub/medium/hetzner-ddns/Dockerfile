# build stage: static Go binary. BLOCKER: upstream targets dns.hetzner.com, shut down May 2026 (see plan.md section 10).
FROM --platform=$BUILDPLATFORM golang:1.27@sha256:5f1b98fa02fe396ebce2a0227a0e08309e11792915b9dd2e1f71053d7e7e6666 AS build

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
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

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
