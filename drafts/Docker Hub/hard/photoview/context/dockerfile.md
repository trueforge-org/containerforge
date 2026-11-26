# Dockerfile (photoview @ f79d379e38241c687c55e9f899e30661fd9f115a)

Source URL: https://github.com/photoview/photoview/blob/f79d379e38241c687c55e9f899e30661fd9f115a/Dockerfile (fetched via raw.githubusercontent.com, pinned commit)

## Stages
1. ui: node:18 (platform ${BUILDPLATFORM:-linux/amd64})
2. api: debian:bookworm (same platform default)
3. final: debian:bookworm-slim (SHELL /bin/bash -o pipefail -c)

## Build args
- UI: REACT_APP_API_ENDPOINT, UI_PUBLIC_URL (default /), VERSION, BUILD_DATE, COMMIT_SHA
- API/final: TARGETPLATFORM
- UI ENV: REACT_APP_BUILD_VERSION, REACT_APP_BUILD_DATE, REACT_APP_BUILD_COMMIT_SHA (derived, defaults undefined/empty)

## UI stage
- WORKDIR /app; COPY ui; `npm ci --omit=dev --ignore-scripts`; `npm run build -- --base=$UI_PUBLIC_URL`

## API stage
- COPY docker/install_build_dependencies.sh -> /tmp/; docker/go_wrapper.sh -> /go/bin/go; api -> /app; WORKDIR /app
- ENV GOPATH=/go, PATH=${GOPATH}/bin:${PATH}, CGO_ENABLED=1
- RUN: chmod +x scripts; run install_build_dependencies.sh; go env; go mod download; sed patch go-face face.go (remove -march=native); go install github.com/mattn/go-sqlite3 and github.com/Kagami/go-face; `go build -v -o photoview .`

## Final stage
- Group photoview GID 999; system user photoview UID 999 (home created)
- apt: curl, gnupg, gpg, libdlib19.1, ffmpeg, exiftool, libheif1, sqlite3
- If TARGETPLATFORM linux/amd64 or linux/arm64: add openSUSE darktable repo for Debian 12 (key via gpg), install darktable
- Purge gnupg/gpg; autoremove; clean; rm /var/lib/apt/lists/*
- WORKDIR /home/photoview
- COPY api/data -> /app/data; ui dist -> /app/ui; api photoview binary -> /app/photoview
- ENV: PHOTOVIEW_LISTEN_IP=127.0.0.1, PHOTOVIEW_LISTEN_PORT=80, PHOTOVIEW_SERVE_UI=1, PHOTOVIEW_UI_PATH=/app/ui, PHOTOVIEW_FACE_RECOGNITION_MODELS_PATH=/app/data/models, PHOTOVIEW_MEDIA_CACHE=/home/photoview/media-cache
- EXPOSE ${PHOTOVIEW_LISTEN_PORT} (80)
- HEALTHCHECK interval 60s, timeout 10s: curl --fail POST http://localhost:${PORT}/api/graphql (siteInfo.initialSetup), exit 1 on fail
- USER photoview
- ENTRYPOINT ["/app/photoview"]; no CMD; no VOLUME

## Gotchas
- Image default listen is 127.0.0.1:80 (ENV); compose overrides PHOTOVIEW_LISTEN_IP=0.0.0.0 to be reachable.
- Runs as UID 999 (not root). Media cache path is /home/photoview/media-cache.
