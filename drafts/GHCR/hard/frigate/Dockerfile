
# Backend-only skeleton from plan.md sections 3 and 4. BLOCKED: see plan.md section 10 (debian:12 upstream, s6, native builds).
# UNVERIFIED items are marked inline.

# Web UI build (node). UNVERIFIED: node version available on this base; npm ci needs a lockfile in web/.
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5 AS web-build

ARG VERSION
USER root

RUN echo "*** Building Frigate web UI ***" && \
  curl -fL -o /tmp/frigate.tar.gz \
    "https://github.com/blakeblackshear/frigate/archive/refs/tags/v${VERSION}.tar.gz" && \
  mkdir -p /tmp/frigate && \
  tar xzf /tmp/frigate.tar.gz -C /tmp/frigate --strip-components=1 && \
  rm /tmp/frigate.tar.gz && \
  cd /tmp/frigate/web && \
  npm ci && \
  npm run build && \
  mkdir -p /output/app/frigate && \
  cp -a /tmp/frigate/web/dist /output/app/frigate/web

# Backend build on the python base. Upstream builds from a pinned commit (a19e23ae) and this uses the release tag.
FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

ARG VERSION
ARG TARGETARCH
USER root

ENV \
  HOME=/config \
  PATH=/usr/local/go2rtc/bin:${PATH}

# UNVERIFIED: ffmpeg package names and version on the base (upstream uses ffmpeg 8.0 from its own builds).
RUN echo "*** Installing runtime dependencies ***" && \
  apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    ffmpeg \
    libusb-1.0-0 && \
  rm -rf /var/lib/apt/lists/*

# go2rtc v1.9.14 binary for the target arch. No checksum is published; the URL is pinned by version.
RUN echo "*** Installing go2rtc ***" && \
  mkdir -p /usr/local/go2rtc/bin && \
  curl -fL -o /usr/local/go2rtc/bin/go2rtc \
    "https://github.com/AlexxIT/go2rtc/releases/download/v1.9.14/go2rtc_linux_${TARGETARCH}" && \
  chmod 0755 /usr/local/go2rtc/bin/go2rtc

# UNVERIFIED: docker/main/requirements.txt was not read in full; the install list must be confirmed.
RUN echo "*** Installing Frigate backend ***" && \
  curl -fL -o /tmp/frigate.tar.gz \
    "https://github.com/blakeblackshear/frigate/archive/refs/tags/v${VERSION}.tar.gz" && \
  mkdir -p /app/frigate && \
  tar xzf /tmp/frigate.tar.gz -C /app/frigate --strip-components=1 && \
  rm /tmp/frigate.tar.gz && \
  python -m venv /app/frigate/venv && \
  /app/frigate/venv/bin/pip install --no-cache-dir -r /app/frigate/docker/main/requirements.txt && \
  install -D -m 0644 /app/frigate/LICENSE /usr/share/licenses/frigate/LICENSE

COPY --from=web-build /output/ /

RUN chown -R apps:apps /app/frigate && chmod -R 755 /app/frigate && \
  rm -rf /tmp/*

USER apps
COPY --chmod=0755 . /

EXPOSE 5000 8554 8555/tcp 8555/udp

VOLUME /config
WORKDIR /app/frigate
