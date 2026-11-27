# Upstream Dockerfile and go.mod: akhilrex/podgrab (commit 032248091294dbf5b6a439a5afd93788a7cc647f)

Source URL(s) + date:
- https://raw.githubusercontent.com/akhilrex/podgrab/032248091294dbf5b6a439a5afd93788a7cc647f/Dockerfile (2026-11-27)
- https://raw.githubusercontent.com/akhilrex/podgrab/032248091294dbf5b6a439a5afd93788a7cc647f/go.mod (2026-11-27)
- https://github.com/akhilrex/podgrab/blob/032248.../Dockerfile: raw variant used

What it is: two-stage Go build. Builder `golang:${GO_VERSION}-alpine`, runtime `alpine:latest`.

Build:
- `ARG GO_VERSION=1.15.2` (see gotchas)
- builder: `apk add alpine-sdk git`, `COPY go.mod go.sum`, `go mod download`, `COPY . .`, `go build -o ./app ./main.go`
- Output: `/api/app`

Runtime (alpine:latest, not pinned):
- `LABEL org.opencontainers.image.source="https://github.com/akhilrex/podgrab"`
- `ENV CONFIG=/config`, `ENV DATA=/assets`, `ENV UID=998`, `ENV PID=100`, `ENV GIN_MODE=release`
- `VOLUME ["/config", "/assets"]`
- `apk add ca-certificates`
- `mkdir /config /assets /api`, `chmod 777 /config /assets`
- `WORKDIR /api`, copies `app`, `client`, `webassets`
- `EXPOSE 8080`
- `ENTRYPOINT ["./app"]`, no CMD, no USER (runs as root; UID/PID env are app-level, not Linux user)

Ports: 8080/tcp.

Volumes/paths: `/config` (CONFIG), `/assets` (DATA). Both chmod 777.

Env vars: CONFIG, DATA, UID, PID, GIN_MODE. Chart adds CHECK_FREQUENCY and PASSWORD (see truecharts-podgrab.md).

go.mod (same commit):
- `module github.com/akhilrex/podgrab`
- `go 1.25.0`
- deps include podcastindex, xmlquery, gin-contrib/location, gin-gonic/gin v1.7.2, gorilla/websocket v1.4.2, stringy.

Gotchas:
- Dockerfile `GO_VERSION=1.15.2` is older than go.mod `go 1.25.0`. The Go 1.15 toolchain cannot build a module that declares go 1.25.0 without a newer toolchain. Not built here; treat as a blocker to verify before building with the pinned base.
- Runtime `alpine:latest` is unpinned.
- No healthcheck or user in Dockerfile.
