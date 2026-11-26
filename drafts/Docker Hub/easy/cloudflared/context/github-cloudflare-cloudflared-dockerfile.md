# cloudflare/cloudflared Dockerfile (pinned commit 518d7f7)

Source URL(s) + fetch date:
- https://github.com/cloudflare/cloudflared/blob/518d7f7969b764df628bb4b1088f0f154901dc4e/Dockerfile (fetched as raw equivalent) · 2026-11-26

## What it is
Upstream multi-stage build of the official `cloudflare/cloudflared` image. Not built by ContainerForge.

## Install/build steps and build deps
- Builder stage: `golang:1.27.4` (alias `builder`).
- Build steps: `go mod download`, then `make cloudflared`.
- Builder ENV: `GO111MODULE=on`, `CGO_ENABLED=0`, `GOPROXY=${GOPROXY}`, `TARGET_GOOS=${TARGET_GOOS}`, `TARGET_GOARCH=${TARGET_GOARCH}`, `CONTAINER_BUILD=1`.
- WORKDIR (builder): `/go/src/github.com/cloudflare/cloudflared/`.
- `COPY go.mod go.sum ./`, `COPY . .`.

## Runtime
- Final stage: `gcr.io/distroless/base-debian13:nonroot` (pinned by sha256 digest starting `a08d9054afba…`).
- `COPY --from=builder --chown=nonroot /go/src/github.com/cloudflare/cloudflared/cloudflared /usr/local/bin/`.
- Final ENV: `NO_AUTOUPDATE=true`.
- `USER 65532:65532`.
- `ENTRYPOINT ["cloudflared"]`, `CMD ["version"]`.
- No `EXPOSE` declared.

## Binaries/entrypoint/CLI flags
- Binary `/usr/local/bin/cloudflared`.

## Build args / ARGs
- Before first stage: `TARGET_GOOS`, `TARGET_GOARCH` (no defaults).
- Builder: `TARGET_GOOS`, `TARGET_GOARCH`, `GOPROXY` (default `https://athens.cfdata.org|https://proxy.golang.org|direct`).

## Gotchas
- `CONTAINER_BUILD=1` is set at build time (builder stage). Per plan.md, this changes metrics bind behavior for container builds (container builds bind `0.0.0.0`). Not independently confirmed in this file beyond the flag being set.
- Upstream image runs as 65532, not `apps`. ContainerForge uses its own `apps` user.
