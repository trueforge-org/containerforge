# ciao — implementation plan
> Source: ./draft.md · Target: apps/ciao/ · Difficulty: medium · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | `1.12.0` (GitHub release, 2026-10-25; matches the draft's tarball link) |
| Renovate | `datasource=github-releases`, `depName=brotandgames/ciao` (tags have no `v` prefix) |
| License | MIT (GitHub; "Copyright (c) 2019 Brot & Games") |
| Source | https://github.com/brotandgames/ciao |
| Download | Source tarball `https://github.com/brotandgames/ciao/archive/refs/tags/1.12.0.tar.gz`, same for both archs; gems are installed from rubygems for the build arch (`sqlite3` gem 2.10.2 has x86_64-linux-gnu and aarch64-linux-gnu platform gems) |
| Checksum | None published for the tarball; UNVERIFIED |
| Upstream Dockerfile | Reviewed (commit 2ae06d3): `ruby:4.0.6-slim` builder (apt `build-essential git libsqlite3-dev tzdata`, `bundle config without 'development test'`, `bundle install`, `rake assets:precompile` with `SECRET_KEY_BASE=foo`) and slim runtime; user uid 1000; `ENV RAILS_LOG_TO_STDOUT=true RAILS_SERVE_STATIC_FILES=true EXECJS_RUNTIME=Disabled`; `VOLUME /app/db/sqlite`; `CMD ./start.sh` |
| Ruby | `.ruby-version` is 4.0.6; Gemfile has no `ruby` constraint. Rails 8.1.4.1, Puma 8.0.2, `net-pop` from `github: ruby/net-pop` (needs git at bundle time; base has git). `Gemfile.lock` is `BUNDLED WITH 4.0.16`. Ubuntu 26.04 `ruby` apt package is `1:3.3build1` (so apt Ruby 3.3, not 4.0.6) |
| Port | 3000 (upstream `start.sh`: `rails server -b 0.0.0.0 -p 3000`) |
| Upstream `start.sh` | Generates `SECRET_KEY_BASE` with `rails secret` if unset, runs `bundle exec rails db:migrate`, removes `tmp/pids/server.pid`, execs `rails server` |
| Env (README) | `SECRET_KEY_BASE`, `TIME_ZONE` (default UTC), `CIAO_LOG_LEVEL` (default WARN), `CIAO_BASE_URL`, `BASIC_AUTH_USERNAME`, `BASIC_AUTH_PASSWORD`, `PROMETHEUS_ENABLED`, `PROMETHEUS_BASIC_AUTH_USERNAME`, `PROMETHEUS_BASIC_AUTH_PASSWORD`, `SMTP_ADDRESS`, `SMTP_PORT`, `SMTP_DOMAIN`, `SMTP_AUTHENTICATION`, `SMTP_ENABLE_STARTTLS_AUTO`, `SMTP_USERNAME`, `SMTP_PASSWORD`, `SMTP_EMAIL_FROM`, `SMTP_EMAIL_TO`, `SMTP_SSL`, `RAILS_MAX_THREADS` |
| Data | SQLite at `db/sqlite/production.sqlite3` (`config/database.yml`). `production.rb` sets `dump_schema_after_migration = false`, so migrate does not write `db/schema.rb` |

## 2. Target layout

```
apps/ciao/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```
No `defaults/` needed. No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` for builder and runtime (Ruby is not in any base; the draft says apt). Closest sibling: `apps/bookstack` (app runtime installed from source on ubuntu).

## 4. Dockerfile

1. `FROM <ubuntu> AS builder`, `ARG VERSION`, `USER root`, `ENV RAILS_ENV=production BUNDLE_WITHOUT=development:test GEM_HOME=/usr/local/bundle BUNDLE_APP_CONFIG=/usr/local/bundle HOME=/tmp`.
2. apt (builder): `ruby ruby-dev build-essential libsqlite3-dev libyaml-dev pkg-config` (git is in the base). `ruby` is a runtime dependency, not the app package, so it is not version-pinned (add `# hadolint ignore=DL3008`); the app ships at `VERSION` via the tarball. Ruby is 3.3 from apt vs upstream 4.0.6: UNVERIFIED whether the lockfile resolves on 3.3. Fallback if not: `COPY --from=docker.io/library/ruby:4.0.6-slim /usr/local /usr/local` (glibc Debian build; check ABI against Ubuntu 26.04) with a renovate comment on that `ARG`.
3. Download `https://github.com/brotandgames/ciao/archive/refs/tags/${VERSION}.tar.gz`, extract to `/app` with `--strip-components=1`.
4. `gem install bundler:4.0.16` (the lockfile's `BUNDLED WITH`; UNVERIFIED that it runs on Ruby 3.3), `bundle config set --local without 'development test'`, `bundle install --jobs $(nproc) --retry 3`, then delete cached `*.gem`, `*.c`, `*.o` as upstream does.
5. `SECRET_KEY_BASE=foo bundle exec rake assets:precompile` (build time), then remove `app/assets lib/assets spec tmp/cache vendor/assets`, as upstream.
6. Final stage `FROM <ubuntu>`, `USER root`: apt runtime only `ruby libsqlite3-0 libyaml-0-2 tzdata` (names to verify; same `ruby` package as builder). `COPY --from=builder /usr/local/bundle /usr/local/bundle` and `COPY --from=builder /app /app`.
7. Make `/app` read-only friendly: `rm -rf /app/db/sqlite /app/log /app/tmp /app/storage` then `ln -s /config/db /app/db/sqlite`, `ln -s /tmp/ciao/tmp /app/tmp`, `ln -s /tmp/ciao/log /app/log`, `ln -s /tmp/ciao/storage /app/storage` (targets are created by `start.sh`). `chown -R root:root /app && chmod -R 755 /app`.
8. `mkdir -p /usr/share/licenses/ciao && cp /app/LICENSE /usr/share/licenses/ciao/`.
9. `ENV RAILS_ENV=production RAILS_LOG_TO_STDOUT=true RAILS_SERVE_STATIC_FILES=true EXECJS_RUNTIME=Disabled GEM_HOME=/usr/local/bundle BUNDLE_WITHOUT=development:test BOOTSNAP_CACHE_DIR=/tmp/bootsnap HOME=/config`, `WORKDIR /app`.
10. `EXPOSE 3000`, `VOLUME /config`.
11. `COPY --chmod=0755 . /`.
12. Final line `USER apps`.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "ciao"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=brotandgames/ciao
  default = "1.12.0"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/brotandgames/ciao"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
  }
  labels = {
    "org.opencontainers.image.source" = "${SOURCE}"
    "org.opencontainers.image.licenses" = "${LICENSE}"
  }
}

target "image-local" {
  inherits = ["image"]
  output = ["type=docker"]
  tags = ["${APP}:${VERSION}"]
}

target "image-all" {
  inherits = ["image"]
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}
```
Validate with `docker buildx bake --print` from `apps/ciao/`. Dockerfile `ARG VERSION` must receive exactly this value (no extra defaults).

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/brotandgames/ciao"
ports:
  - port: 3000
    protocol: tcp
    required: true
env:
  - name: SECRET_KEY_BASE
    default: ""
    required: false
  - name: TIME_ZONE
    default: "UTC"
    required: false
  - name: CIAO_LOG_LEVEL
    default: "WARN"
    required: false
  - name: CIAO_BASE_URL
    default: ""
    required: false
  - name: BASIC_AUTH_USERNAME
    default: ""
    required: false
  - name: BASIC_AUTH_PASSWORD
    default: ""
    required: false
  - name: PROMETHEUS_ENABLED
    default: "false"
    required: false
  - name: SMTP_ADDRESS
    default: ""
    required: false
  - name: SMTP_PORT
    default: ""
    required: false
  - name: SMTP_USERNAME
    default: ""
    required: false
  - name: SMTP_PASSWORD
    default: ""
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```
`SECRET_KEY_BASE` is `required: false` because `start.sh` generates and persists it. No `dependencies:` (SQLite only; draft says none).

## 7. start.sh

1. `mkdir -p /config/db /tmp/ciao/tmp/pids /tmp/ciao/log /tmp/ciao/storage /tmp/bootsnap` (symlink targets; idempotent).
2. Secret: if `SECRET_KEY_BASE` is unset or empty, read `/config/secret_key_base`; if missing, create it once with `umask 077` from `bundle exec rails secret` (or `openssl rand -hex 64`), then `export SECRET_KEY_BASE`. Persisting avoids invalidating sessions on each restart (upstream regenerates every start). Never print it, never put it on the command line.
3. `cd /app`, `bundle exec rails db:migrate` on every start (idempotent; creates `/config/db/production.sqlite3` when empty).
4. `rm -f /app/tmp/pids/server.pid` (resolves through the symlink into `/tmp`).
5. `exec bundle exec rails server -b 0.0.0.0 -p 3000`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '3000'
http:
- port: '3000'
  path: /
filePaths:
- /app/bin/rails
- /usr/share/licenses/ciao/LICENSE
```
Probes for the only port, 3000. The test has no env, so the `SECRET_KEY_BASE`-set path is untestable here and is run manually in section 11.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write | Remap |
|---|---|
| `db/sqlite/` (VOLUME `/app/db/sqlite`, chart PVC `databaselocation`) | symlink to `/config/db` |
| `tmp/` (pids, cache, bootsnap) | symlink to `/tmp/ciao/tmp`; `BOOTSNAP_CACHE_DIR=/tmp/bootsnap` |
| `log/` | `RAILS_LOG_TO_STDOUT=true`, symlink to `/tmp/ciao/log` |
| `storage/` (ActiveStorage) | symlink to `/tmp/ciao/storage` (UNVERIFIED that ciao does not use it for persistent data) |
| `db/schema.rb` | not written (`dump_schema_after_migration = false`) |
| bundler/gem install | build time only, into `/usr/local/bundle` |

Draft expectations (root, writable rootfs, `/app/db/sqlite` PVC) become UID 568, read-only rootfs, `/config/db`. Not privileged. Chart users must remount their old `db/sqlite` data at `/config/db` (file name `production.sqlite3` unchanged).

## 10. Risks, caveats and open questions

- Ruby version mismatch (apt 3.3 vs upstream 4.0.6) and Bundler 4.0.16 may fail; fallback copies Ruby 4.0.6 from the official image. Decide in the first build round.
- Gems with native extensions need `build-essential`, `libsqlite3-dev`, `libyaml-dev` at build time only.
- `net-pop` is fetched from GitHub during `bundle install`; build needs network access to github.com.
- No auth by default (`BASIC_AUTH_*` optional). Password env vars are visible via `docker inspect`.
- Draft said upstream is tracked as `:latest`; the plan pins `1.12.0` via renovate.
- Passwords with special characters in SMTP env vars are consumed only by Rails (no shell or SQL interpolation in `start.sh`).

## 11. Build and test steps

Run per `build-test-protocol.instructions.md`, one app only, max 10 rounds:

```sh
cd apps/ciao
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create ciao-probe-config
docker run --rm -d --name ciao-probe --read-only --tmpfs /tmp \
  -v ciao-probe-config:/config ciao:<VERSION>
docker logs -f ciao-probe        # expect: Puma `Listening on http://0.0.0.0:3000` and `Use Ctrl-C to stop`; migrations complete
docker rm -f ciao-probe; docker volume rm ciao-probe-config
forgetool containers test --image ciao:<VERSION> --config ./apps/ciao/container-test.yaml
```

Always start from an empty `/config` volume and check that the container is still running, with no fatal errors or repeated stack traces. Attempt arm64 only if the amd64 loop is green or the failure is arm64-specific.

## 12. PR checklist

- [ ] Branch `feat/add-ciao` from fresh `main`; one app per PR.
- [ ] Commit and PR title: `feat(ciao): add new container` (Conventional Commits, target `main`).
- [ ] PR body uses `.github/PULL_REQUEST_TEMPLATE.md`, keeps its sections, and only checks boxes that apply.
- [ ] Notes section contains `🤖 This PR is AI generated.` (no "Generated with ..." line).
- [ ] `docker buildx bake --print` exits 0; `VERSION` in `docker-bake.hcl` matches the Dockerfile `ARG VERSION`.
- [ ] Runtime is rootless (`USER apps`) and works with `--read-only --tmpfs /tmp` and an empty `/config`.
- [ ] Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (the `license/cla` check shows status). Only the user can sign it; never sign for them.
- [ ] Untested items stated honestly in the PR: arm64 build, Ruby 3.3 vs 4.0.6 compatibility, SMTP/webhook notifications, Prometheus endpoint, restart persistence of the secret and database.
