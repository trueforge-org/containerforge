# Upstream Dockerfile: dendianugerah/reubah (commit 04469cf)

Source URL: https://raw.githubusercontent.com/dendianugerah/reubah/04469cf95ea7105f9d60e4906eab5533fb70ccd1/Dockerfile (fetched 2026-11-27)

## Builder stage
- `FROM golang:1.22-alpine AS builder`; WORKDIR /app.
- apk: gcc g++ pkgconfig libwebp-dev musl-dev nodejs npm libheif-dev x265-dev libde265-dev bash.
- `COPY go.mod go.sum`; `go mod download`; `COPY . ./`.
- WORKDIR /app/templates: `npm install && npm run build`.
- WORKDIR /app: `CGO_ENABLED=1 go build -o reubah ./cmd/server`.

## Runtime stage
- `FROM alpine:3.19`; WORKDIR /app.
- apk: bash libreoffice ttf-liberation libwebp openjdk11-jre curl libheif-dev x265-dev libde265-dev.
- `mkdir -p /tmp/.cache /tmp/.config /tmp/.local`.
- COPY from builder: /app/reubah → /app/reubah; /app/templates → ./templates; /app/static → ./static.
- `addgroup -g 1000 appgroup`; `adduser -u 1000 -G appgroup -D appuser`; chown /app and /tmp/.cache /tmp/.config /tmp/.local.
- `USER appuser` (UID 1000).

## Env / ports / cmd
- `ENV HOME=/tmp`. No other ENV.
- `EXPOSE 8081`.
- `HEALTHCHECK --interval=30s --timeout=3s CMD curl -f http://localhost:8081/ || exit 1`.
- `CMD ["/app/reubah"]`. No ENTRYPOINT. No VOLUME.

## Gotchas
- Runtime needs LibreOffice (document conversion). Java 11 JRE installed; purpose not documented here.
- Builder and runtime are Alpine (musl). CGO build against musl libs.
