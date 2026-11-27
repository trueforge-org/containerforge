# GitHub: XanderStrike/goplaxt

## Source URL(s) + date
- https://raw.githubusercontent.com/XanderStrike/goplaxt/1607349dea8ce7fb3b8e7ccfb0370d8103d31d61/Dockerfile-amd64
- https://api.github.com/repos/XanderStrike/goplaxt/license
- Fetched 2026-11-27

## License
- MIT (SPDX MIT), LICENSE.txt at master.

## Upstream Dockerfile-amd64 (commit 1607349dea8ce7fb3b8e7ccfb0370d8103d31d61)
### Stages
- builder: `FROM golang:1.12.7-alpine as builder`, `WORKDIR $GOPATH/src/github.com/xanderstrike/goplaxt/`.
- final: `FROM scratch`, `WORKDIR /app`.

### Builder RUN
- `apk add --no-cache git`.
- `mkdir /out`; `mkdir /out/keystore`.
- `GO111MODULE=on CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /out/goplaxt-docker`.
- `COPY . .` into the working directory.

### Final
- `COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt`.
- `COPY --from=builder /out .`; `COPY static ./static`.
- `EXPOSE 8000`.
- `VOLUME /app/keystore/`.
- `ENTRYPOINT ["/app/goplaxt-docker"]`.
- No ENV, USER, CMD, or copied scripts. LABEL maintainer present.

## Runtime deps
- None beyond CA certificates (static Go binary, CGO disabled).

## Ports
- 8000.

## Volumes/paths
- `/app/keystore/` (VOLUME; `/out/keystore` created in builder).
- `/app/static` (web assets).

## User/UID
- Not set; scratch image runs as root by default.

## Arch
- Build hard-codes `GOARCH=amd64`; no TARGETARCH in this Dockerfile.

## Gotchas
- Go 1.12.7 builder (2019-era toolchain).
- Env var names for Trakt credentials/ALLOWED_HOSTNAMES are not in the Dockerfile; they come from the Go source config (not fetched).
- No GitHub releases; pin by commit.
