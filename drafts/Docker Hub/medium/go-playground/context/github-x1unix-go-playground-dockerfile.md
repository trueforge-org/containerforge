# x1unix/go-playground: build/Dockerfile (pinned commit)
Source URL(s): https://github.com/x1unix/go-playground/blob/55b1467ad12c28578a54b80f4dd49f41a64e7a36/build/Dockerfile = https://raw.githubusercontent.com/x1unix/go-playground/55b1467ad12c28578a54b80f4dd49f41a64e7a36/build/Dockerfile (fetched 2026-11-26; raw master variant not fetched)

## Build stages (3-stage)
1. ui-build: node:${NODE_VERSION:-20}-alpine. COPY web -> /tmp/web; `yarn install --silent`; `yarn build` with VITE_* env (VITE_VERSION=APP_VERSION, VITE_GITHUB_URL, VITE_GO_VERSION, VITE_PREV_GO_VERSION, VITE_WASM_API_VER, VITE_WASM_BASE_URL=/wasm, NODE_ENV=production).
2. build: golang:${GO_VERSION:-1.25}-alpine. COPY cmd pkg internal tools go.mod go.sum.
   - `go build -o server -ldflags="-X 'main.Version=$APP_VERSION'" ./cmd/playground`
   - `GOOS=js GOARCH=wasm go build ... -o ./analyzer@$WASM_API_VER.wasm ./cmd/wasm/analyzer`
   - `go run ./tools/pkgindexer imports -o ./data/imports.json` and `index -o ./data/go-index.json`
3. production: golang:${GO_VERSION}-alpine (Go toolchain kept at runtime, GOROOT=/usr/local/go).
   - WORKDIR /opt/playground; COPY ui-build /tmp/web/build -> ./public; server -> ./server; *.wasm and *.js -> ./public/wasm/; data -> ./public/data.

## ARGs
| ARG | Default |
| --- | --- |
| NODE_VERSION | 20 |
| GO_VERSION | 1.25 |
| PREV_GO_VERSION | 1.24 |
| WASM_API_VER | v3 |
| APP_VERSION | 1.0.0 |
| GITHUB_URL | https://github.com/x1unix/go-playground |

## Runtime
- Env: GOROOT=/usr/local/go, APP_CLEAN_INTERVAL=10m, APP_DEBUG=false, APP_PLAYGROUND_URL='https://go.dev/_', APP_GTAG_ID=''
- EXPOSE 8000
- ENTRYPOINT /opt/playground/server -addr=:8000
- Runs as image default user (root; no USER line).
- Gotcha: the runtime needs the Go toolchain image (golang base), not a slim base.
