# Upstream Dockerfile: relvacode/storm @ v1.3.0

Source URL(s) + date: https://raw.githubusercontent.com/relvacode/storm/v1.3.0/Dockerfile (fetched 2026-11-27)

## Build (multi-stage)
- Stage 1: `FROM --platform=${BUILDPLATFORM} golang:alpine as compiler`
  - ARG TARGETOS, TARGETARCH; ENV CGO_ENABLED=0
  - WORKDIR /go/src/storm; COPY . .
  - `GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -ldflags="-s -w" github.com/relvacode/storm/cmd/storm`
- Stage 2: `FROM --platform=${TARGETPLATFORM} alpine`
  - COPY --from=compiler /go/src/storm/storm /usr/bin/storm
  - ENTRYPOINT ["/usr/bin/storm"]

## Runtime
- Alpine base, no USER directive (runs as root), no EXPOSE, no VOLUME, no HEALTHCHECK.
- Static Go binary (CGO disabled), frontend embedded.

## Arch
- Multi-arch via buildx TARGETOS/TARGETARCH.

## Gotchas
- Tag naming: v1.3.0 (git tag). Dockerfile is the upstream build; chart runs it as uid/gid 0.
