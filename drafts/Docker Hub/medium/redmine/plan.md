# redmine — implementation plan
> Source: ./draft.md · Target: apps/redmine/ · Difficulty: medium · Role: main · Verified on 2026-11-25

Redmine is a Rails app. It will not serve without a database, so the database-dependency rule in the build-test protocol needs a decision (section 10).

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `6.1.6`. Latest stable: the docker-library upstream pins `REDMINE_VERSION 6.1.6`, and redmine.org's roadmap lists 6.1.6 as completed and 6.1.7 as still open. Release date of 6.1.6: UNVERIFIED. Chart image is `redmine:6.1.0`; the draft's Dockerfile commit pins 6.1.6, so the draft's version is out of step with its own Dockerfile. |
| Renovate | `// renovate: datasource=github-tags depName=redmine/redmine versioning=semver` (tag naming on the GitHub mirror UNVERIFIED; the tags endpoint could not be queried. If tags do not match, use a custom regex datasource on https://www.redmine.org/releases/) |
| License | GPL-2.0 per `LICENSE.txt` on `master` (https://raw.githubusercontent.com/redmine/redmine/master/LICENSE.txt, "version 2"). GitHub API reports NOASSERTION. Confirm the file at the 6.1.6 tag. |
| Source URL | https://github.com/redmine/redmine (project site https://www.redmine.org/) |
| Per-arch download | Source tarball `https://www.redmine.org/releases/redmine-6.1.6.tar.gz`, architecture-independent. Gems compile per arch at build. Hub `library/redmine:6.1.6-bookworm` and `6.1-bookworm` have amd64 and arm64 (https://hub.docker.com/v2/repositories/library/redmine/tags?page_size=100&name=bookworm). |
| Checksum source | `https://www.redmine.org/releases/redmine-6.1.6.tar.gz.sha256` and the upstream Dockerfile's `REDMINE_DOWNLOAD_SHA256` = `a09f0541e3ef5579de8be1c21fc9cabbd7625d77ec4dd2ddddc39ad9c2c5a483`. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/docker-library/redmine/49a27f29f1d214a4226af75b55578e36d3474c4c/6.1/bookworm/Dockerfile (`ruby:3.4-slim-bookworm`; user `redmine` UID/GID 999; `HOME=/home/redmine`; `RAILS_ENV=production`; `RAILS_LOG_TO_STDOUT=true`; `WORKDIR /usr/src/redmine`; tarball + sha256 check; `bundle config --local without 'development test'`; nokogiri `--use-system-libraries`; `VOLUME /usr/src/redmine/files`; `EXPOSE 3000`; `ENTRYPOINT docker-entrypoint.sh`; `CMD rails server -b 0.0.0.0`) |
| Upstream entrypoint | https://raw.githubusercontent.com/docker-library/redmine/49a27f29f1d214a4226af75b55578e36d3474c4c/6.1/bookworm/docker-entrypoint.sh: `file_env` convention (`*_FILE`), gosu to `redmine` when started as root, fixes permissions on `config log public/*assets tmp files`, writes `config/database.yml` from env when missing (env names beyond `file_env`: UNVERIFIED, read the full script before writing `start.sh`). |
| Port | `3000` (upstream `EXPOSE`, `rails server -b 0.0.0.0`). Confirmed. |
| Env vars (real) | `RAILS_ENV=production`, `RAILS_LOG_TO_STDOUT=true`, `REDMINE_VERSION`, `REDMINE_DOWNLOAD_URL`, `REDMINE_DOWNLOAD_SHA256` (build time). Database and secret env names: UNVERIFIED (not in the fetched portion). |
| Data paths | `/usr/src/redmine/files` (VOLUME upstream), `config`, `log`, `public/assets`, `tmp`, `sqlite`, `db` (upstream Dockerfile). |
| Ruby | Upstream base `ruby:3.4-slim-bookworm`. Minimum Ruby for Redmine 6.1: UNVERIFIED. Ubuntu 26.04 apt `ruby` version: UNVERIFIED (check in the build step). |
| Dependencies | PostgreSQL (chart uses CloudNativePG). ContainerForge `postgresql` app exists (`apps/postgresql`). |

## 2. Target layout

- `apps/redmine/Dockerfile`
- `apps/redmine/docker-bake.hcl`
- `apps/redmine/settings.yaml`
- `apps/redmine/container-test.yaml`
- `apps/redmine/start.sh`

No `defaults/`, `etc/` or `health/` unless a config template is needed (`config/configuration.yml` template is the likely candidate; put it under `etc/` if used). No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`. Ruby has no ContainerForge base, so apt `ruby` and `bundler` are added on ubuntu (the draft's own choice). Closest sibling: `apps/mastodon` (Ruby on Rails on this same base, apt `ruby` + `bundler`, `bundle config` with `without`, `rails assets:precompile`, `S6_STAGE2_HOOK` for an init hook).

## 4. Dockerfile

1. `FROM <ubuntu> AS build`; `ARG VERSION`; `ARG TARGETARCH`; `USER root`.
2. Build apt packages: `ruby`, `ruby-dev`, `bundler`, `build-essential`, `libpq-dev`, `libxml2-dev`, `libxslt1-dev`, `libyaml-dev`, `pkgconf`. Pin against the base release if any package is pinned.
3. Fetch and verify: `curl -fsSL -o /tmp/redmine.tar.gz https://www.redmine.org/releases/redmine-${VERSION}.tar.gz`, then `echo "<sha256>  /tmp/redmine.tar.gz" | sha256sum -c -`. Record the sha256 for each `VERSION` in a comment next to the bake default only if sibling apps do so; otherwise in the Dockerfile as `ARG REDMINE_SHA256`.
4. Extract to `/app/redmine` (`--strip-components=1`). Remove `files/delete.me` and `log/delete.me`.
5. `cd /app/redmine`; `bundle config set --local without 'development test'`; `bundle install --jobs "$(nproc)"`; `RAILS_ENV=production` with a placeholder `SECRET_KEY_BASE` only for `rake assets:precompile` (mastodon precedent), then discard the placeholder. Precompile is UNVERIFIED for Redmine 6.1 (docker-library does not do it).
6. Remove build packages: `apt-get purge -y --auto-remove` for the build set; keep runtime libs (`libpq5`, `libxml2`, `libxslt1.1`, `libyaml-0-2`, `ca-certificates`, `git` only if Redmine's SCM features need it: UNVERIFIED).
7. Final stage `FROM <ubuntu>`; `USER root` for install, then `USER apps`.
8. `COPY --from=build /app/redmine /app/redmine` (or `COPY --chmod=0755 . /` for the start script and any templates).
9. Writable paths: `config/`, `log/`, `tmp/`, `public/assets`, `files/` are not writable under `/app` at runtime. Point them at `/config` and `/tmp` (section 9). `ENV RAILS_ENV=production RAILS_LOG_TO_STDOUT=true HOME=/tmp BUNDLE_APP_CONFIG=/tmp/bundle`.
10. License: `COPY --from=build /app/redmine/LICENSE.txt /usr/share/licenses/redmine/LICENSE.txt`.
11. Tail:

```dockerfile
COPY --chmod=0755 . /
EXPOSE 3000
VOLUME /config
USER apps
```

`CMD` is set by `start.sh` (`exec bundle exec rails server -b 0.0.0.0 -p 3000`).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "redmine"
}

variable "VERSION" {
  // renovate: datasource=github-tags depName=redmine/redmine versioning=semver
  default = "6.1.6"
}

variable "LICENSE" {
  default = "GPL-2.0-only"
}

variable "SOURCE" {
  default = "https://github.com/redmine/redmine"
}
```

`LICENSE` to match the tagged LICENSE.txt (section 1). The four standard targets and the default group are copied from `apps/mastodon/docker-bake.hcl` or `apps/adguardhome-sync/docker-bake.hcl`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/redmine/redmine"
ports:
  - port: 3000
    protocol: tcp
    required: true
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
  - name: SECRET_KEY_BASE
    default: ""
    required: false
  - name: REDMINE_DB_POSTGRES
    default: "postgresql"
    required: false
  - name: REDMINE_DB_DATABASE
    default: "redmine"
    required: false
  - name: REDMINE_DB_USERNAME
    default: "redmine"
    required: false
  - name: REDMINE_DB_PASSWORD
    default: ""
    required: false
volumes:
  - path: /config
    required: true
opt_dependencies:
  - name: postgresql
```

The DB env names above are a plan, not upstream names: verify each against the upstream entrypoint or README before committing (section 1 lists them as UNVERIFIED). Remove any that do not exist. `SECRET_KEY_BASE` is generated into `/config` on first start if unset (see section 7), so it does not need to be required.

## 7. start.sh

- `set -eu`.
- `mkdir -p /config/files /config/secrets /tmp/log /tmp/tmp /tmp/tmp/pids /tmp/tmp/pdf`.
- Secret: if `SECRET_KEY_BASE` is unset, generate one once (`bundle exec rake secret` or `openssl rand -hex 64`) into `/config/secrets/secret_key_base` and read it on later starts. Never log it.
- Write `config/database.yml` into `/tmp` (or a generated file under `/tmp/redmine-config`) from the env vars, only when a DB is configured. Apply DB passwords from env on each start (start-script rule).
- Symlink `/app/redmine/files` to `/config/files` only if `/app/redmine/files` is absent or a symlink; never write into `/app`. Symlinks into `/tmp` for `log`, `tmp`; `ln -sfn` so restarts are idempotent.
- Run `bundle exec rake db:migrate` only if `REDMINE_DB_*` is set and `RUN_DB_MIGRATE` is `true` (add the env var to `settings.yaml` if used). Otherwise skip.
- `cd /app/redmine`; `exec bundle exec rails server -b 0.0.0.0 -p 3000 -e production`.
- Default `admin/admin` login: first-login change is a manual step (inferred; UNVERIFIED for this image).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
# narrowed: requires external postgresql; full functional test not feasible in single-container suite
timeoutSeconds: 180
tcp:
  - port: '3000'
http:
  - port: '3000'
    path: /
filePaths:
  - /app/redmine/config.ru
  - /app/redmine/Gemfile.lock
  - /usr/share/licenses/redmine/LICENSE.txt
```

The `tcp` and `http` checks are real assertions for the declared port. Without a database, the Rails app may answer `/` with a 500 or a redirect instead of 200. Round 1 decides the path: if `/` cannot return 200 without a DB, narrow to a tcp probe plus the process check, and keep the comment above (section 10 criteria). Do not replace the probe with an always-true check.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/usr/src/redmine/files` (VOLUME) | `/config/files`, via symlink created in `start.sh` |
| `config/` (database.yml, configuration.yml, secret) | generated under `/tmp` or `/config/secrets` |
| `log/`, `tmp/`, `tmp/pids`, `tmp/pdf` | `/tmp` (ephemeral; logs go to stdout with `RAILS_LOG_TO_STDOUT=true`) |
| `public/assets` (Rails asset output) | precompiled at build time; if runtime writes occur, `/tmp` symlink |
| bundler config | `BUNDLE_APP_CONFIG=/tmp/bundle`; installed gems are read-only in `/app` |
| `HOME=/home/redmine` upstream | `HOME=/tmp` (`/home` is not writable for `apps`) |

Draft expectations reconciled: chart runs as UID 999 with `fsGroup: 999`, and `readOnlyRootFilesystem: false`. This image runs as `apps` (its UID per base), so the chart's `runAsUser` must change or be overridden. Chart `privileged: false` matches. Persistence `/usr/src/redmine/files` moves to `/config/files`; existing users must copy their files there.

## 10. Risks, caveats and open questions

- **Database is effectively required (blocker for the test):** Redmine does not serve without a database. The protocol's database exception applies only when all three criteria hold, and the draft lists postgresql as `opt_dependencies`. Decide before writing `container-test.yaml`: either declare `postgresql` as a hard dependency (exception applies, narrow the test with the required comment) or keep it optional and accept a narrowed probe. Record the decision in the PR.
- **Ruby version:** Redmine 6.1's minimum Ruby and Ubuntu 26.04's apt Ruby are UNVERIFIED. If apt's Ruby is too old or too new, the build fails: fall back to a pinned Ruby build or report as blocked.
- **Assets precompile:** upstream docker-library does not precompile. Whether Redmine 6.1 serves assets without precompile in production is UNVERIFIED. Test the page in round 1.
- **Admin password:** upstream default `admin/admin`, which must be changed on first login. Document in the PR; do not script a password.
- **Native gems:** `pg`, `nokogiri`, and others compile at build time and need the build packages listed in section 4.
- **Chart version mismatch:** chart pins 6.1.0; this image is 6.1.6. Chart values need updating downstream.
- **arm64:** upstream multi-arch; our source build is per arch through buildx. Not tested by the draft.
- **copy-from arm64:** the draft's `no*` is now answered for the upstream image (multi-arch), but this plan builds from the tarball, so copy-from is informational only.

## 11. Build and test steps

```sh
cd apps/redmine
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name redmine-probe --read-only --tmpfs /tmp \
  -v redmine-probe-config:/config redmine:6.1.6
docker logs -f redmine-probe
forgetool containers test --image redmine:6.1.6 --config ./apps/redmine/container-test.yaml
docker rm -f redmine-probe; docker volume rm redmine-probe-config
```

Expected readiness signal: Rails/Puma log lines `Puma starting` and `Listening on http://0.0.0.0:3000` (text UNVERIFIED for this app version; capture the first 100 lines in round 1). Without a database, expect the process to stay alive with a database connection error logged. Under the database exception, that is a positive signal only together with the process staying alive and no fatal exit (protocol). Run a second round with a real Postgres (`postgresql` app) to confirm `/` returns 200 and the admin login page renders, then clean up.

## 12. PR checklist

- Branch `feat/add-redmine`, commit and PR title `feat(redmine): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections and checkboxes, check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it. The `license/cla` check shows status.
- Say what was not tested: the DB-backed page on `/`, arm64 build, Ruby version check, and the admin first-login flow.
- `docker buildx bake --print` must pass; bake `VERSION` equals Dockerfile `ARG VERSION`.
