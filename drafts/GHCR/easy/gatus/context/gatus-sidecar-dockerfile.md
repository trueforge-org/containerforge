# Upstream Dockerfile and README: home-operations/gatus-sidecar

Source URL(s):
- https://raw.githubusercontent.com/home-operations/gatus-sidecar/1aefae52150e/Dockerfile (fetched 2026-11-27, pinned commit)
- https://raw.githubusercontent.com/home-operations/gatus-sidecar/main/README.md (fetched 2026-11-27, first ~40 lines)

## What it is
- Kubernetes sidecar. Watches Ingress, Service, HTTPRoute, Traefik IngressRoute, and writes Gatus endpoint YAML that Gatus hot-reloads.

## Build steps (from Dockerfile)
```
ARG GO_VERSION
FROM golang:${GO_VERSION}-alpine AS builder
ARG VERSION=dev
ARG REVISION=dev
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -ldflags "-s -w -X main.Version=${VERSION} -X main.Gitsha=${REVISION}" -trimpath -o /out/gatus-sidecar ./cmd/gatus-sidecar

FROM gcr.io/distroless/static:nonroot
COPY --from=builder /out/gatus-sidecar /gatus-sidecar
ENTRYPOINT ["/gatus-sidecar"]
```

## Runtime deps
- None. Static Go binary on `gcr.io/distroless/static:nonroot`.

## Entrypoint/flags
- ENTRYPOINT `["/gatus-sidecar"]`, no CMD.
- Flags seen in chart and README: `--output <path>`, `--auto-service`, `--auto-ingress`, `--auto-httproute`, `--enable-service`, `--enable-ingress`, `--enable-httproute`, `--namespace`, `--ingress-class`, `--gateway-name`.
- README quick start example: `gatus-sidecar --auto-ingress --auto-service --output=./gatus-sidecar.yaml`.

## Env vars
- None set in the Dockerfile.

## Ports
- None exposed (no EXPOSE).

## Volumes/paths
- Writes its output file (`--output`). Chart uses `/config/gatus-sidecar.yaml`. Output contains only `endpoints:`.
- Gatus reads the shared directory (`GATUS_CONFIG_PATH`) and merges all `*.yaml`/`*.yml` files.

## User/UID
- No USER line in the Dockerfile. Base `gcr.io/distroless/static:nonroot` is the non-root variant (its UID is not shown in the fetched content).

## Version/build args
- `GO_VERSION` (no default in the Dockerfile), `VERSION` (default `dev`), `REVISION` (default `dev`).
- Module requires Go 1.27 per plan (go.mod not fetched in this run).

## Arch
- No arch-specific code in the Dockerfile.

## Gotchas
- Upstream image is distroless (no shell). ContainerForge build must produce a glibc Ubuntu-based image instead.
- Reads Kubernetes resources through the API; needs RBAC (see truecharts-gatus.md).
- Repo is static: no state, but the output file lives in the shared `/config` directory.
