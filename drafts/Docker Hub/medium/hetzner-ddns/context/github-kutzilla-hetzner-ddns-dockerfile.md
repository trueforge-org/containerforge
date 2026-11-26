# kutzilla/docker-hetzner-ddns: Dockerfile (commit 511c911)
Source URL(s): https://github.com/kutzilla/docker-hetzner-ddns/blob/511c911/Dockerfile = raw at 511c911 (fetched 2026-11-26, 13 lines)

## Build
- Stage build: golang:1.19-alpine; WORKDIR /app; COPY go.mod go.sum; go mod download; COPY pkg, cmd; `go build -o hetzner-ddns ./cmd/hetzner-ddns`
- Stage final: alpine (unpinned); WORKDIR /; COPY --from=build /app/hetzner-ddns /hetzner-ddns
- ENTRYPOINT ["/hetzner-ddns"]

## Gotchas
- No USER, no EXPOSE, no VOLUME. Runs as root.
- Alpine final stage is unpinned; Go 1.19 builder is old (module go.mod in repo declares its own version, not checked).
