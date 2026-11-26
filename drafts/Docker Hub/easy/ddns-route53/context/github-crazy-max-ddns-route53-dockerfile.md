# crazy-max/ddns-route53 Dockerfile (master, upstream image)

Source URL(s) + fetch date:
- https://github.com/crazy-max/ddns-route53/blob/master/Dockerfile (fetched as raw master) · 2026-11-26
- https://github.com/crazy-max/ddns-route53/blob/d8e3a348afe6152e8919e9f2360ad4fec2a2b323/Dockerfile (pinned commit; same file family, not separately fetched) · 2026-11-26

## Summary
Multi-stage build: `golang:1.26-alpine3.23` (ARG GO_VERSION=1.26, ALPINE_VERSION=3.23) build with `xx` cross-compile; final `alpine:3.23`. Binary copied to `/usr/local/bin/ddns-route53`. User `ddns-route53` uid 1000. ENTRYPOINT `["ddns-route53"]`, CMD `["--config", "/ddns-route53.yml"]`. No EXPOSE, VOLUME, HEALTHCHECK. Release packaging stage builds `ddns-route53_<ver>_<os>_<arch><variant>.tar.gz` (zip for windows) and `checksums.txt` via `sha256sum -b`.

## Build steps
- `xx-go build -trimpath -ldflags "-s -w -X main.version=$(cat /tmp/.version)" -o /usr/bin/ddns-route53 ./cmd`, then `xx-verify --static`.
- Tests: `go test -race ./...`.
- `CGO_ENABLED=0` in base stages (later CGO_ENABLED=1 in test stage with gcc/musl-dev).
- `GOFLAGS=-mod=vendor`.

## Gotchas
- The plan's `FROM alpine` / uid 1000 claim matches. The plan's ldd/static claim is consistent with `xx-verify --static`.
