# itzg/mc-router (upstream v1.57.0)

## Source URL(s) + date
- https://raw.githubusercontent.com/itzg/mc-router/main/Dockerfile
- https://raw.githubusercontent.com/itzg/mc-router/main/README.md (first ~5000 chars only; usage section partly read)
- https://api.github.com/repos/itzg/mc-router/releases/latest
- Fetched 2026-11-26. Plan's pinned Dockerfile blob `bc9198334912` not fetched; main branch used.

## What it is
Routes Minecraft Java client connections to backends by requested hostname (handshake). Multiplexes many servers on one public IP/port. Features: auto-discovery in Kubernetes/Docker, rate limiting, IP allow/deny, webhooks, REST API, Prometheus/InfluxDB metrics, scale-to-zero for K8s StatefulSets.

## Build steps (Dockerfile, main)
- Builder: `golang:1.27.4`. `go mod download` (with cache mounts), then `COPY . .`.
- `CGO_ENABLED=0 go build -buildvcs=false ./cmd/mc-router`.
- Final: `cgr.dev/chainguard/static` (not digest-pinned in Dockerfile).
- `COPY --from=builder /build/mc-router /mc-router`; `ENTRYPOINT ["/mc-router"]`.

## Runtime deps
- None beyond static base (fully static binary).

## Entrypoint/flags
- `/mc-router`. Flags shown in README usage (partial): `-api-binding host:port` (env `API_BINDING`), `-api-key` (env `API_KEY`), `-api-allowed-origins` (env `API_ALLOWED_ORIGINS`), `-auto-scale-allow-deny` (path to allow/deny config). Other flags (port, default, mapping, in-kube-cluster) not seen in fetched portion; env names used by chart: `PORT`, `DEFAULT`, `MAPPING`, `IN_KUBE_CLUSTER`, `KUBE_NAMESPACE`.

## Ports
- Minecraft proxy port (chart: 25565). API port via `API_BINDING` (chart: 25564).

## Version/asset naming
- Latest release (API): tag `v1.57.0`, published 2026-11-26.
- Assets: `mc-router_1.57.0_checksums.txt`, `mc-router_1.57.0_{darwin_amd64,darwin_arm64,linux_amd64,linux_arm64,linux_armv6}.tar.gz`, `mc-router_1.57.0_windows_amd64.zip`.

## Arch
- linux amd64, arm64, armv6; darwin amd64/arm64; windows amd64 (release assets).

## Gotchas
- Chainguard static base has no shell; any entrypoint scripts would not work.
- Docker/Kubernetes auto-discovery depends on labels/annotations described in README (`mc-router.host` label on Docker containers, `externalServerName` annotation on K8s Services).
