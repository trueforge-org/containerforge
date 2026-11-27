# Upstream gitea Dockerfile.rootless + docker-entrypoint.sh (v28.4.0)

## Source URL(s) + date

- https://raw.githubusercontent.com/go-gitea/gitea/v28.4.0/Dockerfile.rootless
- https://raw.githubusercontent.com/go-gitea/gitea/v28.4.0/docker/rootless/usr/local/bin/docker-entrypoint.sh
- Fetched 2026-11-27

## What it is

- Multi-stage build of gitea rootless image.
- Stage `frontend-build`: `--platform=$BUILDPLATFORM docker.io/library/golang:1.27-alpine3.24`; `apk add build-base git nodejs pnpm`; `pnpm install --frozen-lockfile`; `make frontend`.
- Stage `build-env`: `docker.io/library/golang:1.27-alpine3.24`; `ARG GITEA_VERSION`, `ARG TAGS=""`, `ENV TAGS="bindata timetzdata $TAGS"`, `ARG CGO_EXTRA_CFLAGS`.

  - `apk add build-base git`; `go mod download`; copies source; copies `public/assets` from frontend stage.
  - `make backend` (needs `.git/` bind mount for version data).
  - Copies `docker/rootless` to `/tmp/local`; chmod 755 on `/tmp/local/usr/local/bin/*` and the gitea binary.

- Final stage `gitea-rootless`: `docker.io/library/alpine:3.24`.

## Runtime deps (final stage apk)

- bash, ca-certificates, dumb-init, gettext, git, curl, gnupg, openssh-keygen.
- `apk --no-cache upgrade` runs first.

## Entrypoint/flags

- `ENTRYPOINT ["/usr/bin/dumb-init", "--", "/usr/local/bin/docker-entrypoint.sh"]`, `CMD []`.
- Entrypoint script:

  1. Checks `/bin/sh` executable (abort otherwise).
  2. If `/usr/local/bin/docker-setup.sh` exists and is executable, runs it (abort on failure).
  3. If args given: `exec "$@"`.
  4. Else: `exec /usr/local/bin/gitea -c "${GITEA_APP_INI}" web`.

- Dockerfile copies the built binary to `/app/gitea/gitea`. Entrypoint calls `/usr/local/bin/gitea`; the Dockerfile does not show that path being created (the `docker/rootless` overlay was not fetched, so the source of `/usr/local/bin/gitea` is UNVERIFIED).

## Env vars (set by image)

| Var | Value |
| --- | --- |
| GITEA_WORK_DIR | `/var/lib/gitea` |
| GITEA_CUSTOM | `/var/lib/gitea/custom` |
| GITEA_TEMP | `/tmp/gitea` |
| TMPDIR | `/tmp/gitea` |
| GITEA_APP_INI | `/etc/gitea/app.ini` |
| HOME | `/var/lib/gitea/git` |

## Ports

- `EXPOSE 2222 3000`.

## Volumes/paths

- `VOLUME ["/var/lib/gitea", "/etc/gitea"]`, `WORKDIR /var/lib/gitea`.
- `mkdir -p /var/lib/gitea /etc/gitea`; `chown git:git` on both.

## User/UID

- Group `git` gid 1000 (`addgroup -S -g 1000 git`).
- User `git` uid 1000, `-S -H -D`, home `/var/lib/gitea/git`, shell `/bin/bash`.
- `USER 1000:1000`.

## Healthcheck

- None. Comment: "don't use HEALTHCHECK".

## Gotchas

- Build uses `--mount=type=bind,source=".git/"` for version data.
- `COPY --exclude=.git/` used in build stages (BuildKit).
- Entrypoint logs "Executable test for /bin/sh failed" on old Docker; irrelevant to build.
- Final stage does `apk upgrade` on every build.
