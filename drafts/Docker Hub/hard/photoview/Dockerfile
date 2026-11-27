# UNVERIFIED: upstream build dependencies image (photoview/dependencies:trixie) is taken from the upstream
# Dockerfile. Confirm it is public and versioned for this tag, or replace it with package installs
# from the upstream scripts/ helpers.
FROM photoview/dependencies:trixie@sha256:8c3e34eaa10310d7f2026ecee8ad525626dd6d02de8a0bb793b91d54da49b1cf AS dependencies

# UNVERIFIED: the Node major is not pinned by the plan. Upstream uses node:18, which is EOL.
FROM node:22-trixie-slim@sha256:f0960f8dc047f358e3fb428f36ccba21732194fa5f0cac849f401e63e62fb9e6 AS ui
ARG VERSION
ENV UI_PUBLIC_URL=/ \
  npm_config_cache=/tmp/npm
# No checksum is published for the tag archive, so none is verified here.
ADD https://github.com/photoview/photoview/archive/refs/tags/v${VERSION}.tar.gz /tmp/photoview.tar.gz
RUN mkdir -p /src && \
  tar -xzf /tmp/photoview.tar.gz --strip-components=1 -C /src && \
  cd /src/ui && \
  npm ci && \
  npm run build && \
  rm -rf /tmp/photoview.tar.gz /tmp/npm

# Go binaries are built in this stage only. Version tracks the go.mod of the pinned tag (UNVERIFIED).
FROM golang:1.27-trixie@sha256:430985542100b871e108ccc00e8dcc5eef08ca14ee5825e98ebf563d8ffec4ee AS api
ARG VERSION
ENV \
  CGO_ENABLED=1 \
  GOCACHE=/tmp/gocache \
  GOMODCACHE=/tmp/gomodcache \
  GOPATH=/tmp/gopath
ADD https://github.com/photoview/photoview/archive/refs/tags/v${VERSION}.tar.gz /tmp/photoview.tar.gz
COPY --from=dependencies /usr/local/lib/ /usr/local/lib/
RUN mkdir -p /src /out && \
  tar -xzf /tmp/photoview.tar.gz --strip-components=1 -C /src && \
  ldconfig && \
  # UNVERIFIED: apply the go-face patch from the upstream Dockerfile here. It drops
  # -march=native and -lcblas so the binary runs on other CPUs. The exact command is not in the plan.
  cd /src/api && \
  go build -v -o /out/photoview . && \
  cp -r /src/api/data /out/data && \
  rm -rf /tmp/photoview.tar.gz /tmp/gocache /tmp/gomodcache

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

USER root

ENV \
  HOME=/config \
  PHOTOVIEW_LISTEN_IP=0.0.0.0 \
  PHOTOVIEW_LISTEN_PORT=8080 \
  PHOTOVIEW_SERVE_UI=1 \
  PHOTOVIEW_UI_PATH=/app/ui \
  PHOTOVIEW_API_ENDPOINT=/api \
  PHOTOVIEW_FACE_RECOGNITION_MODELS_PATH=/app/data/models \
  PHOTOVIEW_MEDIA_CACHE=/cache \
  PHOTOVIEW_SQLITE_PATH=/config/photoview.db

# UNVERIFIED: runtime libraries must match the libraries the api stage links against (see the
# upstream runtime_deps script). The list is not in the plan, so it is not guessed here.
# ffmpeg is the Ubuntu package; upstream ships jellyfin-ffmpeg, which may differ.
RUN echo "*** Installing Photoview runtime dependencies ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    ffmpeg && \
  rm -rf /var/lib/apt/lists/*

COPY --from=dependencies /usr/local/lib/ /usr/local/lib/
COPY --from=api /out/photoview /app/photoview
COPY --from=api /out/data /app/data
COPY --from=ui /src/ui/dist /app/ui
COPY --from=api /src/LICENSE.md /usr/share/licenses/photoview/LICENSE.md

RUN echo "*** Finalising ***" && \
  ldconfig && \
  chown -R apps:apps /app && chmod -R 755 /app && \
  echo "*** Cleaning Up ***" && \
  rm -rf /tmp/*

USER apps
COPY --chmod=0755 . /

EXPOSE 8080

VOLUME /config
