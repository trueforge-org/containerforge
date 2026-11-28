# docuseal — implementation plan
> Source: ./draft.md · Target: apps/docuseal/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | Latest release is 3.4.0 (`releases/latest` redirects to https://github.com/docusealco/docuseal/releases/tag/3.4.0). The draft uses 3.3.8, which is older. Plan targets 3.4.0; bump the draft's chart tag accordingly. Tags have no `v` prefix. |
| Renovate | `datasource=github-releases depName=docusealco/docuseal versioning=semver`. |
| License | AGPL-3.0 (LICENSE begins "GNU AFFERO GENERAL PUBLIC LICENSE Version 3"). The README describes the license as "AGPLv3 License with Section 7(b) Additional Terms", and the repo has a `LICENSE_ADDITIONAL_TERMS` file (copied into the image by the Dockerfile; its text not fetched). A bare SPDX `AGPL-3.0-only` may not capture that, so decide at port time. |
| Source URL | https://github.com/docusealco/docuseal |
| Downloads | No binary release assets (expanded assets list empty). Source tarball `https://github.com/docusealco/docuseal/archive/refs/tags/${VERSION}.tar.gz` (both arches; app is interpreted Ruby). Gems via bundler, JS via yarn/Shakapacker. |
| Checksum | None published for the tag archive. UNVERIFIED; pin by tag. |
| Upstream Dockerfile reviewed | https://github.com/docusealco/docuseal/blob/a628dd30daafde9f2e7b9ef161a3a9b7c6f4d9fc/Dockerfile (draft's commit, 3.3.8). Three stages on `ruby:4.0.10-alpine`: (1) download fonts (GoNotoKurrent, DancingScript), license files, ONNX model `model_704_int8.onnx` and musl pdfium zip (sha256-checked per arch); (2) webpack build with nodejs, yarn, git, build-base and Shakapacker; (3) runtime with apk `libpq vips redis onnxruntime leptonica jemalloc font-liberation font-carlito` plus build deps removed afterwards. ENV: `RAILS_ENV=production BUNDLE_WITHOUT=development:test OPENSSL_CONF=/etc/openssl_legacy.cnf HOME=/home/docuseal WORKDIR=/data/docuseal VIPS_MAX_COORD=17000 VIPS_BLOCK_UNTRUSTED=1 MALLOC_CONF=...`. `EXPOSE 3000`, no `VOLUME`, runs as root (no `USER`), `CMD /app/bin/bundle exec puma -C /app/config/puma.rb --dir /app`. Writable: `/app/tmp`, `/app/tmp/cache`, `/app/log`, `/data/docuseal`. The pdfium binary downloaded is a musl build, a glibc build is needed on Ubuntu (UNVERIFIED source, see 10). The 3.4.0 Dockerfile was re-read on 2026-11-26: same three-stage layout on `ruby:4.0.10-alpine`, same ENV and CMD; not diffed line by line against 3.3.8. |

## 2. Target layout

```
apps/docuseal/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```
Possibly `defaults/openssl_legacy.cnf` (upstream sets `OPENSSL_CONF=/etc/openssl_legacy.cnf`, created in its Dockerfile; content UNVERIFIED). No `root/`, no `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`. Ruby is not a ContainerForge base. Use a multi-stage build: a build stage on the same ubuntu image (apt `ruby`, `ruby-dev`, `build-essential`, `nodejs`, `yarnpkg`, `libpq-dev`, `libyaml-dev`, `git`), then `COPY --from` into a final ubuntu stage with only runtime packages. UNVERIFIED: Ubuntu 26.04 ruby apt version versus upstream's pinned Ruby 4.0.10 (Gemfile/.ruby-version must be checked; if too old, install Ruby from source or `ruby-install` into `/usr/local` in the build stage). Closest sibling: `apps/bookstack` (PHP web app seeded from `/defaults`, DB dependency); `apps/mastodon` (also Rails) is the nearest Rails precedent and should be read for gem/asset handling before porting.

## 4. Dockerfile

1. Build stage: `ARG VERSION`; `apt-get install` ruby toolchain, nodejs, yarn, libpq-dev, libvips-dev; download source tarball; `bundle config set without 'development test'`, `bundle install` into `/app/vendor/bundle` (gem path under `/app`, caches `BUNDLE_APP_CONFIG=/tmp/bundle`, `GEM_HOME` off `/config`); `yarn install` and `bin/shakapacker` with `RAILS_ENV=production NODE_ENV=production`, yarn/npm caches in `/tmp`.
2. Fetch assets as upstream: fonts, ONNX model into `/app/tmp/model.onnx` -> must be at a read-only path (`/app/model/model.onnx`; the app's configured path UNVERIFIED), pdfium glibc build (UNVERIFIED URL; upstream pins musl zip with sha256, get the matching Linux glibc zip from the same pdfium-binaries project and checksum).
3. Final stage `USER root`: `apt-get install -y --no-install-recommends libpq5 libvips42t64 redis-server? ` (only if upstream really needs a local redis, UNVERIFIED), `libonnxruntime`/`onnxruntime` (UNVERIFIED availability on Ubuntu; else fetch from Microsoft release), `libleptonica6`, `libjemalloc2`, `fonts-liberation`, `fonts-crosextra-carlito`; exact package names and versions UNVERIFIED and must be checked with `apt-cache policy`.
4. Copy built app to `/app`, make read-only (`chown -R root:root`, `chmod -R a+rX`). License files (AGPL text, fonts, pdfium, onnx licenses) to `/usr/share/licenses/docuseal/`.
5. `ENV RAILS_ENV=production RAILS_LOG_TO_STDOUT=true HOME=/config WORKDIR=/config/data TMPDIR=/tmp VIPS_MAX_COORD=17000 VIPS_BLOCK_UNTRUSTED=1`.
6. `COPY --chmod=0755 . /`, `EXPOSE 3000`, `VOLUME /config`, `USER apps`.

## 5. docker-bake.hcl

`APP=docuseal`, `VERSION=3.4.0`,
```hcl
// renovate: datasource=github-releases depName=docusealco/docuseal versioning=semver
```
`LICENSE=AGPL-3.0-only`, `SOURCE=https://github.com/docusealco/docuseal`. Four standard targets and the `default` group; validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/docusealco/docuseal"
ports:
  - port: 3000
    protocol: tcp
    required: true
env:
  - {name: WORKDIR, default: "/config/data", required: false}
  - {name: DATABASE_URL, default: "", required: false}
  - {name: SECRET_KEY_BASE, default: "", required: false}
  - {name: TZ, default: "Etc/UTC", required: false}
volumes:
  - path: /config
    required: true
dependencies:
  - postgresql   # ✅ apps/postgresql exists
```
Only `WORKDIR` is verified from the upstream Dockerfile. `DATABASE_URL` is confirmed by the upstream README: it selects PostgreSQL or MySQL, and "by default the container uses SQLite" when it is unset. Where the SQLite file lands under `WORKDIR` is not confirmed. `SECRET_KEY_BASE` is not mentioned by any fetched source and is UNVERIFIED. This default is what lets the container start with no env.

## 7. start.sh

- `mkdir -p /config/data /tmp/docuseal/{tmp,log}`; symlink or env-point Rails `tmp`/`log` to `/tmp` (since `/app/tmp`, `/app/log` are read-only): set `RAILS_LOG_TO_STDOUT=true`, `TMPDIR=/tmp`, and check how `/app/tmp/cache` is used (bootsnap cache `BOOTSNAP_CACHE_DIR=/tmp/bootsnap`).
- Generate `SECRET_KEY_BASE` once into `/config/data/.secret_key_base` when the env var is empty (umask 077), export it from the file on later starts. Do not put it in the process list.
- Run `bundle exec rails db:prepare` (upstream behavior at boot UNVERIFIED; check 3.4.0's `config/puma.rb`/entrypoint) on each start; idempotent.
- Bind `0.0.0.0:3000` via puma (`-b tcp://0.0.0.0:3000` or env `PORT`; UNVERIFIED which upstream uses).
- `cd /app && exec bundle exec puma -C /app/config/puma.rb --dir /app`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 240
tcp:
  - port: '3000'
http:
  - port: '3000'
    path: /   # may answer with a redirect to /setup; verify which status the probe accepts (UNVERIFIED)
filePaths:
  - /app/bin/bundle
  - /usr/share/licenses/docuseal/LICENSE
```
`timeoutSeconds` is a guess (Rails boot with asset compile is not needed at runtime; check against `apps/mastodon`). Database narrowing: the exception does not apply as long as SQLite fallback works without a DB; if it does not, then all three criteria hold (hard `postgresql` dependency, no start without it, no sidecar primitive) and the tests may be narrowed with the comment `# narrowed: requires external postgresql; full functional test not feasible in single-container suite`.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/data/docuseal` (WORKDIR, attachments, SQLite) | `/config/data` via `WORKDIR` |
| `/app/tmp`, `/app/tmp/cache` | `/tmp` (symlink created at build: `/app/tmp -> /tmp/app-tmp`, dir made by start.sh) |
| `/app/log` | stdout (`RAILS_LOG_TO_STDOUT`) or `/tmp` |
| `/app/public/packs` | build-time only, read-only at runtime |
| `/app/tmp/model.onnx` | read-only path in image |
| `/home/docuseal` | `HOME=/config` |

Draft expects UID 0, writable rootfs, `/data` persistence. Reconciliation: `USER apps`, read-only rootfs, single persistent volume `/config` (draft's `/data` becomes `/config/data`). Document the migration for existing `/data` users.

## 10. Risks, caveats and open questions

- Ruby version gap on Ubuntu (UNVERIFIED) and the musl-only pdfium/onnxruntime artifacts upstream uses: a glibc source must be found for each arch.
- Large build (gems, yarn, Shakapacker); read `apps/mastodon` first for precedent.
- Draft says PostgreSQL is required; whether SQLite fallback works for the container test is UNVERIFIED.
- Upstream runs `Ruby 4.0.10` (Ruby 4.0 release is recent, apt packaging may lag).
- AGPL network clause plus additional terms (section 7) should be reviewed by maintainers before publishing.
- Draft version 3.3.8 is stale; 3.4.0 Dockerfile not reviewed, re-read it at port time.

## 11. Build and test steps

```sh
cd apps/docuseal
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name docuseal-probe --read-only --tmpfs /tmp \
  -v docuseal-probe-config:/config docuseal:3.4.0
docker logs -f docuseal-probe
docker rm -f docuseal-probe; docker volume rm docuseal-probe-config
forgetool containers test --image docuseal:3.4.0 --config ./apps/docuseal/container-test.yaml
```
Also run once with `-e DATABASE_URL=postgres://...` against `apps/postgresql`, since the test cannot set env. Expected readiness: Puma's `Listening on http://0.0.0.0:3000` (standard Puma line, UNVERIFIED for this config).

## 12. PR checklist

- Branch `feat/add-docuseal`, commit `feat(docuseal): add new container`, PR template filled, only applicable boxes checked.
- Notes: `🤖 This PR is AI generated.`
- CLA: tell the user, https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Untested: everything (build, asset compile, gem install, runtime, Postgres path, arm64).
