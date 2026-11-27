# minekube/gate (upstream)

## Source URL(s) + date
- https://raw.githubusercontent.com/minekube/gate/master/Dockerfile
- https://raw.githubusercontent.com/minekube/gate/master/README.md
- https://raw.githubusercontent.com/minekube/gate/master/LICENSE
- https://api.github.com/repos/minekube/gate/releases/latest
- Fetched 2026-11-26. Plan's pinned Dockerfile blob `f47fd8c3ec6f` not fetched; master used.

## What it is
Gate: extensible Minecraft proxy written in Go. Bedrock cross-play via managed Geyser/Floodgate (`bedrock: true`). Docs at gate.minekube.com (not fetched).

## License
Apache License 2.0.

## Build steps (Dockerfile, master)
- Build stage: `golang:1.27` (platform `$BUILDPLATFORM`). Copies `go.mod go.sum`, `go mod download`, then `cmd`, `pkg`, `gate.go`.
- `ARG TARGETOS TARGETARCH`, `ARG VERSION=unknown`.
- `CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH go build -ldflags="-s -w -X 'go.minekube.com/gate/pkg/version.Version=${VERSION}'" -a -o gate gate.go`.
- Runtime-deps stage: `debian:bookworm-slim`, copies `libz.so.1` from `/usr/lib/*-linux-gnu/` to `/runtime-libs` (for arm64 geyserlite).
- Final `gate` stage: `gcr.io/distroless/base-debian12` (glibc, not `static`, because the binary needs the glibc loader); copies binary to `/`, libz to `/usr/lib/libz.so.1`.
- `ENV XDG_CACHE_HOME=/var/cache/gate`; `VOLUME ["/var/cache/gate"]`; `ENTRYPOINT ["/gate"]`.
- Alternate `jre` stage: `eclipse-temurin:25.0.5_8-jre` (glibc JRE, not alpine), binary at `/usr/local/bin/gate`, `PATH` prepends `/opt/java/openjdk/bin`, `ENTRYPOINT ["/usr/local/bin/gate"]`.

## Runtime deps
- glibc (distroless/base-debian12) + libz.so.1 (for arm64 geyserlite).
- Dynamic loader needed even with CGO_ENABLED=0 (purego libdl import). Static-only base crashes with "exec /gate: no such file or directory".

## Entrypoint/flags
- `/gate` (gate image), `/usr/local/bin/gate` (jre image).

## Volumes/paths
- `/var/cache/gate` (VOLUME; XDG_CACHE_HOME).

## Config
- Config via YAML (README: `bedrock: true` for managed Bedrock). Full config docs on gate.minekube.com (not fetched).

## Version/asset naming
- Latest release (API): tag `v0.82.3`, published 2026-11-22.
- Assets: `checksums.txt`; `gate_0.82.3_{darwin_amd64,darwin_arm64,linux_386,linux_386_musl,linux_amd64,linux_amd64_musl,linux_arm64,linux_arm64_musl}`; `gate_0.82.3_windows_{386,amd64,arm64}.exe`.
- Naming: `gate_<version>_<os>_<arch>[_musl]`, no archive wrapper (raw binaries).

## Arch
- darwin, linux (386, amd64, arm64; musl variants), windows (386, amd64, arm64). Dockerfile uses TARGETOS/TARGETARCH.

## Gotchas
- Dockerfile comment says the arm64 geyserlite binary is dynamically linked and needs zlib.
- ARG VERSION default `unknown` (must be passed for version string).
