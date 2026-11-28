# tracks — implementation plan
> Source: ./draft.md · Target: apps/tracks/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | v2.7.1 (published 2024-07-25, https://api.github.com/repos/tracksapp/tracks/releases/latest). Upstream has no release assets. Chart image `ghcr.io/tracksapp/tracks:latest` is unpinned, so pin the tag v2.7.1 (or a newer tag if one is found at build time). |
| Draft correction | Draft says "Rails 3.3". Upstream `Gemfile.lock` on master pins `rails (7.2.3.2)` and upstream Dockerfile uses `ARG RUBY_VERSION=3.3`. Target is Rails 7.2 on Ruby 3.3. |
| Renovate | `datasource=github-releases depName=tracksapp/tracks versioning=loose` (tag format not checked: UNVERIFIED) |
| License | GPL-2.0 (GitHub SPDX `GPL-2.0`, https://api.github.com/repos/tracksapp/tracks) |
| Source URL | https://github.com/tracksapp/tracks |
| Download | Source archive `https://github.com/tracksapp/tracks/archive/refs/tags/v2.7.1.tar.gz` (UNVERIFIED: URL not fetched). No prebuilt binary. Built with bundler on Ruby 3.3 per arch. |
| Checksum source | None published upstream. Pin by tag; record the sha256 of the archive at build time (UNVERIFIED: tag-to-commit SHA not looked up). |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/tracksapp/tracks/8dcca98c6c48404d8328bbee220a8b19d48799ce/Dockerfile: `ARG RUBY_VERSION=3.3`, `FROM ruby:${RUBY_VERSION} AS base`, WORKDIR /app, stages base/precompile/production/test/development, apt `npm netcat-openbsd`, npm global `yarn`, gem `bundler`, EXPOSE 3000, no ENV, no VOLUME, no USER (runs root), ENTRYPOINT `/app/docker-entrypoint.sh`, CMD `./bin/rails server -b 0.0.0.0`. |
| Ports | 3000/tcp (http) (EXPOSE in upstream Dockerfile) |
| Env vars | UNVERIFIED: DB config keys. The `config/database.yml` sample was not found on master by the fetch; read the repo's `config/` at build time before writing `start.sh`. |
| Data paths | Dockerfile creates `/app/log`. UNVERIFIED: whether Rails writes `tmp/`, `public/assets`, `storage/` at runtime. |
| Ruby on Ubuntu | UNVERIFIED: Ubuntu 26.04 apt `ruby` version. If it is not 3.3, use the official `ruby:3.3` build stage pattern or a pinned Ruby build (decision in section 10). |

## 2. Target layout

- `apps/tracks/Dockerfile`
- `apps/tracks/docker-bake.hcl`
- `apps/tracks/settings.yaml`
- `apps/tracks/container-test.yaml`
- `apps/tracks/start.sh` (replaces upstream `docker-entrypoint.sh`)

Also `apps/tracks/defaults/` only if a `config/database.yml` template is needed for seeding into `/config` (reason: the app reads DB settings from a file). No `root/`, no `etc/`, no `health/` unless the test needs them. No `DOWNSTREAM_CHANGES.md` (not a FROM base).

## 3. Base image

Final stage and build stage: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`. Ruby comes from apt (`ruby-full`, `build-essential`, `libyaml-dev`, `libpq-dev` as needed for native gems) in a build stage; the gems are installed to `/app/vendor/bundle`. Ruby is not in the base image; there is no `ruby` ContainerForge base. Closest sibling: `apps/webgrabplus` (dotnet on ubuntu, build then runtime).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Build stage on the ubuntu base: apt `ruby-full build-essential libyaml-dev libpq-dev libffi-dev git ca-certificates` (not in base: confirm with `apt-cache policy`). Pin ruby/apt versions against the Ruby version the Gemfile needs.
3. Download the source archive `https://github.com/tracksapp/tracks/archive/refs/tags/v${VERSION}.tar.gz` with curl, verify the sha256 recorded in the Dockerfile, extract to `/app`. Then copy `config/database.docker.yml` to `config/database.yml` and `config/site.docker.yml` to `config/site.yml`, as the upstream Dockerfile does.
4. `gem install bundler`, `bundle config set --local path /app/vendor/bundle`, `bundle install --without development test`, `RAILS_ENV=production bundle exec rails assets:precompile` (SECRET_KEY_BASE set to a build-time dummy only for precompile).
5. Copy `/usr/share/doc` and upstream `LICENSE` to `/usr/share/licenses/tracks/`.
6. `ENV HOME=/config`, `RAILS_LOG_TO_STDOUT=1`, `RAILS_ENV=production`, `TMPDIR=/tmp`, `BUNDLE_PATH=/app/vendor/bundle`. Caches (bundle, tmp) must stay under `/tmp` or `/config`.
7. `chown -R apps:apps /app` (read-only at runtime, so keep ownership but no writes: `log/`, `tmp/` are redirected in `start.sh`).
8. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 3000`, `VOLUME /config`.

Avoid `apt` in the final stage. Remove build packages in the same layer or use a separate runtime stage (runtime needs `ruby` and `libpq5` only).

## 5. docker-bake.hcl

- `APP = "tracks"`, `SOURCE = "https://github.com/tracksapp/tracks"`, `LICENSE = "GPL-2.0-only"` (SPDX form to confirm against the repo's `LICENSE` file: UNVERIFIED).
- `VERSION` with `// renovate: datasource=github-releases depName=tracksapp/tracks versioning=loose` and `default = "2.7.1"`.
- Standard targets: `docker-metadata-action`, `image`, `image-local`, `image-all`, and `group "default" { targets = ["image-local"] }`.
- Validate: `cd apps/tracks && docker buildx bake --print`.

## 6. settings.yaml

- Schema header and `schema_version: 1`, `upstream_env_url: "https://github.com/tracksapp/tracks"`.
- `ports`: `3000` tcp, `required: true`.
- `env`: only variables `start.sh` or the app reads, each with `name`, `default`, `required`. Candidates: `TZ` (`Etc/UTC`), `SECRET_KEY_BASE` (required, generated on first start if missing and stored in `/config`), `DATABASE_URL` or the DB keys found in the repo's config (UNVERIFIED names).
- `volumes`: `/config` (`required: true`) for generated secrets, DB config and any writable state.
- `dependencies`: a database engine is required (not named by the draft). UNVERIFIED which engine; if `apps/postgresql` or `apps/mariadb` is the chosen engine, list it under `dependencies` (both exist in `apps/`). Do not add an optional dependency that the app does not read.

## 7. start.sh

- `set -eu`; no writes to `/app`.
- On first start, create `/config/secret_key_base` (random, `openssl rand -hex 64`) only if missing; export `SECRET_KEY_BASE` from it.
- Seed `/config/database.yml` from `defaults/` only if missing. Re-read DB settings from env on every start.
- Make `log/` and `tmp/` point at `/tmp` (symlink from `/app/log` to `/tmp/log`) so the read-only rootfs works.
- Run `bundle exec rails db:prepare` (idempotent) before the server.
- Bind `-b 0.0.0.0 -p 3000`.
- Final line: `exec bundle exec rails server -b 0.0.0.0 -p 3000` (PID 1 handoff).

## 8. container-test.yaml

- forgetool schema header from sibling apps (e.g. `apps/bazarr/container-test.yaml`).
- `tcp` probe on 3000 with `timeoutSeconds` copied from a Rails sibling (no Rails sibling exists: use the adguardhome-sync value and check the log readiness line).
- `filePaths`: `/config/database.yml` after seed and the `start.sh` seed path, since test runs have no env vars.
- Expected readiness signal: `Listening on` or `Use Ctrl-C to stop` in logs.
- Narrow DB assertions only if all three criteria of the protocol exception hold: `# narrowed: requires external database; full functional test not feasible in single-container suite`.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/app/log` | symlink to `/tmp/log` in `start.sh` (or `RAILS_LOG_TO_STDOUT=1`) |
| `/app/tmp` | symlink to `/tmp/rails-tmp` |
| `/app/public/assets` | written at build time only; read-only at runtime |
| `/app/storage` (if used) | `/config/storage` via symlink (UNVERIFIED: whether used) |
| Bundler cache | `/tmp` |

Run as `apps` (not root). Upstream runs as root: the image must not. Verify `docker run --read-only --tmpfs /tmp` works.

## 10. Risks, caveats and open questions

- Draft says Rails 3.3: corrected to Rails 7.2 on Ruby 3.3 per upstream `Gemfile.lock` (see section 1). Plan follows the upstream pin.
- Ruby version: Ubuntu 26.04 ruby vs Ruby 3.3. UNVERIFIED. If it differs, a pinned Ruby build is needed (a blocker until decided).
- Native gems (for example pg, nokogiri, bcrypt) need build deps; arm64 is a source build with native gems (draft said arm64 `yes`; this is compile-class, not a binary download).
- External database: engine not named by the draft. UNVERIFIED which DBs are supported.
- No upstream checksum for the source tarball; pin by tag and record sha256.
- Chart image tag is `latest`. Pin `v2.7.1`, the last release, which is from 2024. Newer master commits exist (pushed 2026-08-03): decide whether to pin master instead (UNVERIFIED).
- Blockers: none confirmed. Ruby version and DB engine must be settled before the Dockerfile.

## 11. Build and test steps

From `apps/tracks/`:

1. `docker buildx bake --print`
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. `docker volume create tracks-probe-config`, `docker run --rm -d --name tracks-probe --read-only --tmpfs /tmp -v tracks-probe-config:/config tracks:2.7.1`, `docker logs -f tracks-probe` (expect `Listening on` and no fatal error), then `docker rm -f tracks-probe; docker volume rm tracks-probe-config`.
4. `forgetool containers test --image tracks:2.7.1 --config ./apps/tracks/container-test.yaml`.

Round limit: 10. Clean up scratch containers and volumes between rounds.

## 12. PR checklist

- Branch `feat/add-tracks`, commit `feat(tracks): add new container`, PR title the same.
- PR body uses `.github/PULL_REQUEST_TEMPLATE.md`; Notes contain `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it).
- Say what was not tested: arm64 build, DB engine, the Ruby version choice if still UNVERIFIED.
- Check "Built container locally" only if the build actually ran.
