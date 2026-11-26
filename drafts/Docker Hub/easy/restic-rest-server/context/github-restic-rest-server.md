# restic/rest-server (GitHub)

Source URL(s) + fetch date (2026-11-26):
- https://github.com/restic/rest-server (repo; README via https://raw.githubusercontent.com/restic/rest-server/master/README.md)
- https://raw.githubusercontent.com/restic/rest-server/master/Dockerfile (draft cites blob/master/Dockerfile)
- https://raw.githubusercontent.com/restic/rest-server/v0.14.0/Dockerfile (draft cites blob/v0.14.0/Dockerfile)
- https://github.com/restic/rest-server/releases/tag/v0.15.0 (release page; asset list did not render)
- Not fetched (direct downloads, patterns recorded below): releases/download/v${VERSION#v} (contains ${), rest-server_0.14.0_dragonfly_amd64.tar.gz, rest-server_0.14.0_linux_arm64.tar.gz, rest-server_0.15.0_linux_amd64.tar.gz, rest-server_0.15.0_linux_arm64.tar.gz, SHA256SUMS

## What it is
"A high performance HTTP server that implements restic's REST backend API." Restic clients reach it with a `rest:` URL. BSD-2-Clause, written in Go.

## Build and requirements
- Go 1.26 or newer (v0.15.0 changelog). Only the official Go compiler is tested.
- Compatible with restic v0.7.1 or newer.
- Build: `CGO_ENABLED=0 go build -o rest-server ./cmd/rest-server`.

## Dockerfile (master; same shape at v0.14.0)
```
FROM golang:alpine AS builder
ENV CGO_ENABLED=0
COPY . /build
WORKDIR /build
RUN go build -o rest-server ./cmd/rest-server

FROM alpine:3.24            # v0.14.0 used `FROM alpine`
ENV DATA_DIRECTORY=/data
ENV PASSWORD_FILE=/data/.htpasswd
RUN apk add --no-cache --update apache2-utils tzdata   # v0.14.0: apache2-utils only
COPY docker/create_user /usr/bin/
COPY docker/delete_user /usr/bin/
COPY docker/entrypoint.sh /entrypoint.sh
COPY --from=builder /build/rest-server /usr/bin
VOLUME /data
EXPOSE 8000
CMD [ "/entrypoint.sh" ]
```
- No ARG, USER, HEALTHCHECK or ENTRYPOINT in the Dockerfile. Start is via CMD `/entrypoint.sh`.
- Master adds tzdata (v0.15.0 changelog #388: Docker image includes timezone data so TZ works).

## Entrypoint (docker/entrypoint.sh, per plan.md; not fetched directly)
- `DISABLE_AUTHENTICATION` set: adds `--no-auth`. Otherwise creates `$PASSWORD_FILE` with umask 027 if missing and warns when empty.
- Then `exec rest-server --path "$DATA_DIRECTORY" --htpasswd-file "$PASSWORD_FILE" $OPTIONS`.

## CLI flags (README)
| Flag | Notes |
| --- | --- |
| `--append-only` | allow new backups, block deletion or modification |
| `--cpu-profile string` | write CPU profile to file |
| `--debug` | debug messages |
| `--group-accessible-repos` | filesystem group can access repo files (does not change existing perms) |
| `--htpasswd-file string` | default `<data directory>/.htpasswd` |
| `--listen string` | default `":8000"` |
| `--log filename` | combined-log-format HTTP requests; `-` for stdout |
| `--max-size int` | max repo size in bytes |
| `--no-auth` | disable .htpasswd authentication |
| `--no-verify-upload` | skip upload integrity checks (low-power devices only) |
| `--path string` | default `/tmp/restic` (Linux/BSD) |
| `--private-repos` | users reach only their own repo |
| `--prometheus` / `--prometheus-no-auth` | metrics at `/metrics` |
| `--proxy-auth-username string` | header carrying username (basic auth disabled when set) |
| `--proxy-headers` | trust X-Forwarded-For, X-Real-IP, Forwarded (off by default) |
| `--tls`, `--tls-cert`, `--tls-key` | TLS; keys at data dir root per README |
| `--tls-min-ver string` | `1.2` (default) or `1.3` |
| `-v, --version` | print version |

## Env vars
| Name | Default | Purpose |
| --- | --- | --- |
| DATA_DIRECTORY | /data | data directory (`--path`) |
| PASSWORD_FILE | /data/.htpasswd | htpasswd file |
| OPTIONS | empty | extra rest-server flags |
| DISABLE_AUTHENTICATION | unset | any value adds `--no-auth` |
| TZ | (tzdata installed in master) | timezone |

Not present: RESTIC_REST_USERNAME / RESTIC_REST_PASSWORD (README does not document them).

## Ports
- 8000/tcp (EXPOSE, default `--listen :8000`).

## Volumes/paths and persistent data
- `/data` (VOLUME). Binary default data path `/tmp/restic` (backups can be lost there).

## User/UID and permissions
- No USER in the image (runs as root by default). README: any user works with `--user "$(id -u):$(id -g)"`; combined with `--read-only`, only `/data` must be writable by that user.

## Auth
- Enabled by default. Server refuses to start if .htpasswd cannot be opened unless `--no-auth`.
- Create users with `htpasswd -B -c .htpasswd username` (bcrypt or SHA only).
- Docker helpers: `create_user myuser [password]`, `delete_user myuser` via `docker exec`.
- Proxy auth: usernames may contain letters, digits, `@ . _ -`.

## Healthcheck/readiness
- `/healthz` endpoint returns HTTP 204 with empty body (v0.15.0 changelog #259). Not in the Dockerfile.
- Metrics at `/metrics` with `--prometheus`.

## Version/release info and asset naming
- Latest release v0.15.0 (tag v0.15.0, commit 650b5a0, 23 Nov 2026 20:46, marked Latest, signed by fd0). Release notes: security fix for failed .htpasswd reload retries (#420); WWW-Authenticate header on rejected Basic auth (#376); upload temp file leak fix (#385); credential cache 1 minute (#386); Go 1.26 required (#373); `--proxy-headers` (#233); `/healthz` (#259); tzdata in image (#388). Release page reports 40 assets; names did not render.
- Asset naming (per plan.md, not fetched): `rest-server_<VERSION>_linux_<amd64|arm64>.tar.gz`, archive dir `rest-server_<VERSION>_linux_<arch>/` containing `rest-server`, `LICENSE`, `README.md`, `CHANGELOG.md`; `SHA256SUMS` and `SHA256SUMS.asc`.
- Older naming seen in draft: `rest-server_0.14.0_dragonfly_amd64.tar.gz` (wrong OS for Linux; plan.md says the draft amd64 link is a bug).

## Arch support
- Linux amd64 and arm64 release tarballs (per plan.md). Docker Hub page lists none.

## Gotchas
- Draft v0.14.0 is outdated; v0.15.0 is latest.
- Use `linux_amd64`, not `dragonfly_amd64`.
