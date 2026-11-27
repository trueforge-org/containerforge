# UNVERIFIED: base and digest taken from plan.md section 3 (ubuntu 26.04). Node 22 comes from apt.
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454 AS build

ARG VERSION
ARG TARGETARCH
USER root

# TODO (UNVERIFIED): the upstream build workflow was not read. Build the server bundle and the web, admin and
# mobile frontends from the tag exactly as upstream CI does, and leave them in the layout the final stage copies.
# TODO: pin the tag commit SHA once verified (no checksum is published). Build tools are added here only if the upstream build needs them.
RUN \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    nodejs=22.22.1+dfsg+~cs22.19.15-1ubuntu1 && \
  mkdir -p /build && \
  curl -fsSL -o /tmp/affine.tar.gz \
    "https://github.com/toeverything/AFFiNE/archive/refs/tags/v${VERSION}.tar.gz" && \
  tar -xzf /tmp/affine.tar.gz -C /build --strip-components=1 && \
  rm -rf /tmp/* /var/lib/apt/lists/*

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION
ARG TARGETARCH
USER root

# Node 22 from apt (same pin as the build stage). libjemalloc2 is kept from upstream.
# ca-certificates is already in the base image and is not installed again.
RUN \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    nodejs=22.22.1+dfsg+~cs22.19.15-1ubuntu1 \
    libjemalloc2 \
    openssl && \
  # UNVERIFIED: the jemalloc path; the symlink gives LD_PRELOAD a fixed path on every architecture.
  ln -s "$(find /usr/lib -name libjemalloc.so.2 | head -n1)" /usr/lib/libjemalloc.so.2 && \
  apt-get clean && \
  rm -rf /tmp/* /var/lib/apt/lists/*

# TODO: copy the frontend dist output into /app/static, /app/static/admin and /app/static/mobile once the build exists.
# UNVERIFIED: that packages/backend/server is the right bundle root and that scripts/ and dist/ are present in it.
COPY --from=build /build/packages/backend/server /app

ENV HOME=/config
ENV XDG_CACHE_HOME=/tmp
ENV NODE_ENV=production
ENV LD_PRELOAD=/usr/lib/libjemalloc.so.2

COPY --chmod=0755 . /

USER apps

EXPOSE 3010

VOLUME /config
