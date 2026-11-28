# passwordpusher — implementation plan
> Source: ./draft.md (folder `passwordpusherephemeral`) · Target: apps/passwordpusher/ · Difficulty: hard (Ruby 4.0 on a base that ships Ruby 3.3, Rails assets build, upstream image is Alpine) · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | **v2.17.4** (release 2026-11-19). The draft image `pwpush-ephemeral:latest` is a rolling tag. |
| Key finding | `containers/docker/pwpush-ephemeral/Dockerfile` (draft link) is `FROM pwpush:latest`, adds an "END OF SUPPORT" banner to `entrypoint.sh`, and sets `ENV DATABASE_URL=sqlite3:db/db.sqlite3`. Upstream says to migrate to the universal image (`pglombardo/pwpush`, built from `containers/docker/Dockerfile`). So the plan builds the universal image and reproduces the ephemeral behaviour as a configuration default (SQLite, no external services), rather than copying an unsupported image. |
| Renovate | `datasource=github-releases depName=pglombardo/PasswordPusher versioning=semver extractVersion=^v(?<version>.+)$` |
| License | Apache-2.0 (GitHub SPDX). |
| Source URL | https://github.com/pglombardo/PasswordPusher (docs https://docs.pwpush.com/). Tarball `https://github.com/pglombardo/PasswordPusher/archive/refs/tags/v2.17.4.tar.gz`. |
| Upstream Dockerfile | `containers/docker/Dockerfile` at v2.17.4 reviewed: two stages on `ruby:4.0.10-alpine`; build deps incl. `libpq-dev mariadb-dev sqlite-dev yaml-dev yarn nodejs`; `bundle config without development:test`, `deployment true`; `yarn install --frozen-lockfile`; `SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile`; runtime user UID 1000; `EXPOSE 80 443 5100`; entrypoint `containers/docker/entrypoint.sh`. |
| Ruby | `.ruby-version` and `Gemfile.lock` pin **4.0.10**; `Gemfile` requires `>=3.4.3`. Ubuntu 26.04 (resolute) ships `ruby3.3` 3.3.8 only (no `ruby3.4`/`ruby4.0` source packages), so the base Ruby is too old. `docker.io/library/ruby:4.0.10-slim-trixie` exists with amd64 and arm64. |
| Ports | Thruster listens on `HTTP_PORT` (script `bin/web`; **80** by default when `TARGET_PORT` is set) and proxies to Puma on `TARGET_PORT` (entrypoint sets 5100 unless `PORT` is given). Upstream exposes 80, 443, 5100. Draft's "public gateway 5000" is not found in the upstream sources; `Dockerfile.public-gateway` exposes the same 80/443/5100 and is a runtime variant via env `PWP_PUBLIC_GATEWAY`. |
| Entrypoint behaviour | Generates `SECRET_KEY_BASE` if unset (or reads `SECRET_KEY_BASE_FILE`), default `DATABASE_URL=sqlite3:storage/db/production.sqlite3`, runs `bundle exec rake db:migrate`, then `foreman start -m "web=1,worker=1,metrics=N"` (worker off if `PWP__NO_WORKER` or `PWP_PUBLIC_GATEWAY` set; metrics on if `PWP__PROMETHEUS__ENABLED=true`). Solid Queue runs in `async` mode inside the same process (`SOLID_QUEUE_SUPERVISOR_MODE=async`). |
| Env verified in sources | `SECRET_KEY_BASE`, `SECRET_KEY_BASE_FILE`, `DATABASE_URL`, `PORT`, `HTTP_PORT`, `TARGET_PORT`, `PWP__NO_WORKER`, `PWP_PUBLIC_GATEWAY`, `PWP__PROMETHEUS__ENABLED`, `PWP__HOST_DOMAIN`, `PWP__HOST_PROTOCOL`, `PWP__OVERRIDE_BASE_URL` (all in `entrypoint.sh`, `bin/web`, `config/settings.yml`), `RAILS_LOG_TO_STDOUT` (`config/environments/production.rb`). `PWP__THEME`/`PWP_PRECOMPILE` trigger asset recompilation at start and cannot work on a read-only filesystem. |
| Checksum source | `Gemfile.lock` and `yarn.lock` pin dependencies; no checksum for the tarball. Ruby comes from the official image (digest-pin it). |

## 2. Target layout

```
apps/passwordpusher/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```
No `defaults/`, no `root/`, no `DOWNSTREAM_CHANGES.md`. App folder is `passwordpusher` (the draft's `-ephemeral` variant is end-of-support upstream; the "ephemeral" mode is just the SQLite default with `/config` not persisted).

## 3. Base image

Final stage `ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a` plus a Ruby copied from `docker.io/library/ruby:4.0.10-slim-trixie` (pin its digest when implementing; digest UNVERIFIED here). Debian trixie glibc (2.41) is older than Ubuntu 26.04's, so the copied binaries run. Closest sibling: `apps/mastodon` (Rails on ubuntu with apt Ruby; here apt Ruby is too old).

## 4. Dockerfile

1. Stage `build` (ubuntu 26.04, `USER root`, `ARG VERSION`, `HOME=/tmp`): `COPY --from=docker.io/library/ruby:4.0.10-slim-trixie /usr/local /usr/local`; apt (build-only): `build-essential pkg-config git libpq-dev libmariadb-dev libsqlite3-dev libyaml-dev libffi-dev libssl-dev`; runtime libs for the final stage are listed in step 4. Node is already in the base; yarn v1 via `corepack prepare yarn@1.22.22 --activate` (the lock file is v1 style, since upstream uses `yarn install --frozen-lockfile`).
2. Download the tarball to `/app/passwordpusher` (`--strip-components=1`). `bundle config set without development:test`, `bundle config set deployment true`, `bundle config set path vendor/bundle`, `bundle install`, remove gem caches and `.git` as upstream does, `yarn install --frozen-lockfile`, `SECRET_KEY_BASE_DUMMY=1 RAILS_ENV=production bundle exec rails assets:precompile`, `rm -rf tmp/cache tmp/pids tmp/sockets log/* .do .github test containers`. `BUNDLE_APP_CONFIG=/tmp/bundle`, `GEM_HOME` under the app dir, caches in `/tmp`.
3. Replace writable app paths with symlinks created at build time: `rm -rf storage tmp log && ln -s /config/storage storage && ln -s /tmp/pwpush/tmp tmp && ln -s /tmp/pwpush/log log` (real directories are created by `start.sh`; `/config` and `/tmp` are empty at first start).
4. Final stage (ubuntu 26.04, `USER root`): `COPY --from=build /usr/local /usr/local`, `COPY --from=build --chown=568:568 /app/passwordpusher /app/passwordpusher`; apt runtime packages not in the base: `libpq5 libmariadb3 libsqlite3-0 libyaml-0-2 libffi8 libjemalloc2 tzdata`. Copy `LICENSE` to `/usr/share/licenses/passwordpusher/LICENSE`.
5. `ENV RAILS_ENV=production RACK_ENV=production RAILS_LOG_TO_STDOUT=true HTTP_PORT=8080 TARGET_PORT=5100 SOLID_QUEUE_SUPERVISOR_MODE=async LD_PRELOAD=/usr/lib/<multiarch>/libjemalloc.so.2 HOME=/tmp TMPDIR=/tmp BUNDLE_APP_CONFIG=/tmp/bundle BUNDLE_DEPLOYMENT=true BUNDLE_WITHOUT=development:test` (check the jemalloc path per arch, or drop `LD_PRELOAD`).
6. `USER apps`, `COPY --chmod=0755 . /`, `WORKDIR /app/passwordpusher`, `EXPOSE 8080 5100`, `VOLUME /config`; no `CMD` (the ubuntu `ENTRYPOINT` execs `/start.sh`). The Dockerfile ends with `USER apps`.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "passwordpusher" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=pglombardo/PasswordPusher versioning=semver extractVersion=^v(?<version>.+)$
  default = "2.17.4"
}
variable "RUBY_VERSION" {
  // tied to .ruby-version / Gemfile.lock of the app at VERSION; bump together with VERSION, no renovate
  default = "4.0.10"
}
variable "LICENSE" { default = "Apache-2.0" }
variable "SOURCE"  { default = "https://github.com/pglombardo/PasswordPusher" }
```
`target "image"` passes `VERSION` and `RUBY_VERSION`. Standard targets: `docker-metadata-action`, `image`, `image-local` (`type=docker`, tag `${APP}:${VERSION}`), `image-all` (amd64, arm64), `group "default"` = `image-local`. Validate with `docker buildx bake --print`. The Ruby image `FROM`/`COPY --from` tag in the Dockerfile must equal `RUBY_VERSION`.

## 6. settings.yaml

Schema header, `schema_version: 1`, `upstream_env_url: "https://github.com/pglombardo/PasswordPusher"`.
- ports: `8080` tcp (Thruster, public), `5100` tcp (Puma, direct), both `required: false`. Both are really opened (the same Rails server answers on both).
- env: `TZ` (`Etc/UTC`); `SECRET_KEY_BASE` (default `""`, required false: `start.sh` generates a per-boot key, so sessions reset on restart; set it for stable sessions); `DATABASE_URL` (default `sqlite3:storage/db/production.sqlite3`, i.e. `/config/storage/db/production.sqlite3`; for the ephemeral variant mount `/config` as tmpfs); `PWP__HOST_DOMAIN` (`""`), `PWP__HOST_PROTOCOL` (`https`, upstream default in `settings.yml`), `PWP__OVERRIDE_BASE_URL` (`""`); `PWP__NO_WORKER` (`""`); `PWP__PROMETHEUS__ENABLED` (`false`); `HTTP_PORT` (`8080`); `TARGET_PORT` (`5100`).
- volumes: `/config` `required: true` (holds `storage/`: SQLite database and Active Storage files).
- dependencies: none required (SQLite default). opt_dependencies: `postgresql` ✅ (`apps/postgresql`) via `DATABASE_URL=postgres://...`.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail
mkdir -p /config/storage/db /tmp/pwpush/tmp /tmp/pwpush/log
if [ -z "${SECRET_KEY_BASE:-}" ] && [ -n "${SECRET_KEY_BASE_FILE:-}" ]; then SECRET_KEY_BASE="$(tr -d '[:space:]' < "$SECRET_KEY_BASE_FILE")"; fi
if [ -z "${SECRET_KEY_BASE:-}" ]; then echo "SECRET_KEY_BASE not set; generating one for this boot"; SECRET_KEY_BASE="$(ruby -rsecurerandom -e 'puts SecureRandom.hex(64)')"; fi
export SECRET_KEY_BASE
export DATABASE_URL="${DATABASE_URL:-sqlite3:storage/db/production.sqlite3}"
export HTTP_PORT="${HTTP_PORT:-8080}" TARGET_PORT="${TARGET_PORT:-5100}"
cd /app/passwordpusher
bundle exec rake db:migrate
prom="${PWP__PROMETHEUS__ENABLED:-false}"; metrics=0; [ "${prom,,}" = "true" ] && metrics=1
workers=1; { [ -n "${PWP__NO_WORKER:-}" ] || [ -n "${PWP_PUBLIC_GATEWAY:-}" ]; } && workers=0
exec bundle exec foreman start -m "web=1,worker=${workers},metrics=${metrics}"
```
Points: idempotent (`db:migrate` is a no-op once current), seeds only missing dirs, never writes `/app` (symlinked `storage`, `tmp`, `log`), no secret written to disk or argv, upstream's `.env.production` write is skipped, `exec` on foreman. Thruster binds `0.0.0.0:${HTTP_PORT}`; verify Puma on 5100 also answers from outside the container.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 240
tcp:
- port: '8080'
- port: '5100'
http:
- port: '8080'
  path: /
- port: '5100'
  path: /
filePaths:
- /app/passwordpusher/VERSION
- /app/passwordpusher/db/migrate
- /usr/share/licenses/passwordpusher/LICENSE
```
Both ports from settings.yaml are probed. No env needed: SQLite and a generated secret make it boot completely, so the real stack is tested. `/` may redirect depending on `PWP__HOST_PROTOCOL`; if the redirect fails the probe, point the probe at a stable path such as `/up` (Rails default health route, UNVERIFIED that it is routed here) rather than weakening the check.

## 9. Rootless and read-only-rootfs adaptations

- Draft expects UID/GID 0 and `readOnlyRootFilesystem: false`; upstream runs as UID 1000 and writes under the app dir. Here UID 568, read-only rootfs.
- Upstream write paths: `storage/` (SQLite, Active Storage) -> `/config/storage`; `tmp/` (bootsnap, cache, pids, sockets) -> `/tmp/pwpush/tmp`; `log/` -> stdout (`RAILS_LOG_TO_STDOUT`) with a `/tmp` symlink as fallback; `.env.production` (entrypoint appends secrets to it) -> not used; `db/schema.rb` rewrite after migrate (production default is no dump; UNVERIFIED for this app, test with `--read-only`); asset compile at start (`PWP__THEME`, `PWP_PRECOMPILE`) -> unsupported, themes are chosen at build time.
- Thruster binds `HTTP_PORT` 80 by default, impossible for UID 568 without a sysctl; the image overrides it to 8080.
- Draft: no extra persistence; here `/config` is optional (only needed to keep SQLite data).

## 10. Risks, caveats and open questions

- Upstream image is end-of-support; the plan switches to the universal image. Confirm with maintainers that the ephemeral flavour is expressed only via config.
- Ruby 4.0.10 via `COPY --from` of an official image: not an apt package and not renovate-tracked; its digest must be pinned and bumped with the app. Alternative: build Ruby from source with `ruby-build` (slower).
- Native gems (pg, mysql2, sqlite3, bootsnap) compile against Ubuntu libs; libs in the final stage must match (`libmariadb3` name on resolute UNVERIFIED).
- Draft guesses "public gateway on 5000": not present in upstream; dropped.
- arm64: bootsnap precompile is amd64-only upstream; skip on arm64 or drop it.
- A public base URL is needed for links (`PWP__OVERRIDE_BASE_URL`, or `PWP__HOST_DOMAIN` + `PWP__HOST_PROTOCOL`); behind TLS termination the default `https` protocol is right.
- Multiple processes (foreman: Thruster + Puma + Solid Queue) are inherent upstream; `PWP__NO_WORKER` splits workers off.

## 11. Build and test steps

```sh
cd apps/passwordpusher
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name passwordpusher-probe --read-only --tmpfs /tmp -v passwordpusher-probe-config:/config passwordpusher:2.17.4
docker logs -f passwordpusher-probe   # expect "SECRET_KEY_BASE not set; generating", db:migrate output, foreman starting web.1/worker.1, Puma "Listening on http://0.0.0.0:5100"
curl -fsS -o /dev/null -w '%{http_code}\n' http://<container-ip>:8080/
curl -fsS -o /dev/null -w '%{http_code}\n' http://<container-ip>:5100/
docker rm -f passwordpusher-probe; docker volume rm passwordpusher-probe-config
# restart once on the same volume to check idempotent migrations; then run with DATABASE_URL pointing at a postgresql sidecar
forgetool containers test --image passwordpusher:2.17.4 --config ./apps/passwordpusher/container-test.yaml
```

## 12. PR checklist

- [ ] Branch `feat/add-passwordpusher`, commit and title `feat(passwordpusher): add new container`, target `main`.
- [ ] PR body follows `.github/PULL_REQUEST_TEMPLATE.md`, only applicable boxes checked.
- [ ] Notes section contains `🤖 This PR is AI generated.`
- [ ] Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it).
- [ ] Bake and Dockerfile `VERSION` and `RUBY_VERSION` aligned; `docker buildx bake --print` run.
- [ ] State untested items: arm64, PostgreSQL mode, themes, Prometheus exporter, public-gateway mode, behaviour of `db:migrate` on a read-only rootfs until it is run.
