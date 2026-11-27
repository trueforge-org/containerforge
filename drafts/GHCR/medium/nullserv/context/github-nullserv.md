# Upstream: bmrzycki/nullserv (repo, README, Dockerfile)

Source URL(s) + date:
- https://github.com/bmrzycki/nullserv (2026-11-27, HTML, mostly navigation)
- https://raw.githubusercontent.com/bmrzycki/nullserv/master/README.md (2026-11-27)
- https://raw.githubusercontent.com/bmrzycki/nullserv/master/Dockerfile (2026-11-27)
- https://github.com/bmrzycki/nullserv/releases/latest (HTML, 2026-11-27): no version text extracted
- https://api.github.com/repos/bmrzycki/nullserv/releases/latest: 403

What it is: "Minimal null file web server in Go". Serves minimal valid files (images, text) for URL suffixes, so ad-blocked requests get valid responses. Listens on HTTP 80 and HTTPS 443 and aborts TLS early. Written originally in Go 1.5; no third-party packages. Version seen in README sample: `1.3.0`.

Build (from README): `make` (generates buildinfo.go and file2gobyte), or manually `sh mkbuildinfo.sh` then `go build -o nullserv *.go`. Dockerfile also present.

Dockerfile (master):
- Build stage: `FROM golang:alpine AS build-env`, WORKDIR `/go/src/app`, `COPY . .`, `./mkbuildinfo.sh`, `CGO_ENABLED=0 GOOS=linux go build -a -ldflags '-w -extldflags "-static"' -o nullserv *.go`
- Final: `FROM scratch`, `COPY --from=build-env /go/src/app/nullserv /`
- `ENTRYPOINT ["/nullserv"]`, no CMD, no USER, no EXPOSE, no VOLUME. Scratch image has no shell or user database.

Entrypoint flags (`-h` output from README):
| Flag | Meaning | Default |
| --- | --- | --- |
| -a | http address | all |
| -p | http port | 80 |
| -A | https address | all |
| -P | https port | 443 |
| -m | content cache age (secs) | 31536000 |
| -v | verbose level | 0 |
| -c | JSON config file (overrides flags; keys in conf.go, example_confs/all.json) | none |

Ports: 80/tcp (http), 443/tcp (https) by default.

User/UID: none set. Binding 80/443 as non-root needs `net.ipv4.ip_unprivileged_port_start` (README recommends an OS-level sysctl, then reset to 1024). Go setuid/setgid issue noted in README.

Env vars: none.

Volumes/paths: none required. Binary is self-contained (no external files, except optional JSON config).

Healthcheck/internal endpoints: `/.ver` or `/.version` (JSON: build_date, commit_date, reset_date, sha, version); `/.stat` or `/.stats` (request counters: http_*, https_*, stats_*, suffix_*).

Config files: optional JSON via `-c` (example: `{ "max_age" : -1 }`).

Arch: pure Go with CGO off, so the build is portable across Go GOOS/GOARCH.

Gotchas:
- Dockerfile runs `./mkbuildinfo.sh` inside the build context; that script is required at build time.
- No CA/cert files needed: HTTPS is a deliberate TLS abort, so no certificate is shipped.
