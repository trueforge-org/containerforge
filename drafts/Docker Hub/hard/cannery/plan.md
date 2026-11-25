# cannery — implementation plan
> Source: ./draft.md · Target: apps/cannery/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | 1.5.9 (tag, 2026-11-22). The draft says 1.5.8 (2026-11-19); use 1.5.9 |
| Renovate | `datasource=gitlab-tags depName=shibaobun/cannery versioning=semver` |
| License | AGPLv3 per the GitLab project page. SPDX: `AGPL-3.0-or-later` UNVERIFIED (only-vs-or-later not checked in LICENSE.md) |
| Source URL | https://gitlab.com/shibaobun/cannery |
| Download | No binary. Source tarball `https://gitlab.com/shibaobun/cannery/-/archive/${VERSION}/cannery-${VERSION}.tar.gz` (both archs, compile) |
| Checksum | None published; pin the tag only |
| Upstream Dockerfile | The raw `Dockerfile` URLs returned 404 (probed main, dev), so it was NOT reviewed. The draft's link is `.../-/blob/1.5.8/Dockerfile`; re-check with the tag when porting. README says the image `shibaobun/cannery` contains `/app/priv/random.sh` and `/app/priv/cloak_key.sh` |
| Port | 4000 (README) |
| Env (README) | required `HOST`, `SECRET_KEY_BASE`, `CLOAK_KEY`; `PORT` (4000), `DATABASE_URL` (default `ecto://postgres:postgres@cannery-db/cannery`), `ECTO_IPV6` (false), `POOL_SIZE` (10), `REGISTRATION` (`invite` default or `public`), `LOCALE` (`en_US`,`de`,`fr`,`es`), `DISABLE_EMAIL`, `SMTP_HOST`, `SMTP_PORT` (587), `SMTP_USERNAME`, `SMTP_PASSWORD`, `SMTP_SSL` (false), `EMAIL_FROM`, `EMAIL_NAME`, `UPLOADS_PATH` (default `/var/cannery/uploads`) |
| Notes | First registered account becomes admin. Uploads must be outside static files and shared across app containers |

## 2. Target layout

`Dockerfile` (multi-stage), `docker-bake.hcl`, `settings.yaml`, `container-test.yaml`, `start.sh`. No `defaults/` (no config file). No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

Final stage `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` (an Elixir release bundles ERTS, so no Erlang is needed at runtime; only libssl, libncurses, libstdc++ equivalents, UNVERIFIED).
Build stage: an Elixir toolchain image or ubuntu plus apt `erlang`/`elixir`; required Elixir/OTP versions UNVERIFIED (read `mix.exs` `elixir:` and `.tool-versions` at the tag). Pin the builder by digest, and match the builder's glibc to the runtime (Ubuntu 26.04) to avoid ABI problems, so prefer an ubuntu 26.04 builder with apt/asdf toolchain. Closest sibling: none for Elixir; Go build-stage pattern of `COPY --from` applies.

## 4. Dockerfile

1. Build stage: `ARG VERSION`; install `erlang`, `elixir`, `git`, `build-essential`, `nodejs/npm` only if assets need it (Phoenix 1.7 uses esbuild/tailwind via mix, downloaded at build; UNVERIFIED). Download the tag tarball, `MIX_ENV=prod mix deps.get --only prod && mix assets.deploy && mix release`. HEX/MIX caches in `/tmp` (`HEX_HOME`, `MIX_HOME`).
2. Final stage: `USER root`; apt install runtime libs only (`libssl3`, `libncurses6`, `libstdc++6`; check before adding, UNVERIFIED). `COPY --from=build /build/_build/prod/rel/cannery /app`. Also copy `priv/random.sh` and `priv/cloak_key.sh` if they are not inside the release.
3. License: `/usr/share/licenses/cannery/LICENSE.md`.
4. `ENV HOME=/config RELEASE_TMP=/tmp UPLOADS_PATH=/config/uploads PORT=4000` (`RELEASE_TMP` is the standard mix release temp dir).
5. `chown -R apps:apps /app`, `COPY --chmod=0755 . /`, `EXPOSE 4000`, `VOLUME /config`, `USER apps`.

## 5. docker-bake.hcl

APP `cannery`; VERSION `1.5.9` with `// renovate: datasource=gitlab-tags depName=shibaobun/cannery versioning=semver`; LICENSE `AGPL-3.0-or-later`; SOURCE `https://gitlab.com/shibaobun/cannery`. Four standard targets, default group `image-local`. `docker buildx bake --print` must pass.

## 6. settings.yaml

Schema header, `schema_version: 1`, `upstream_env_url: "https://gitlab.com/shibaobun/cannery"`.
ports: 4000/tcp.
env: `HOST` (default `localhost`, required), `SECRET_KEY_BASE` (required; start.sh generates and stores one in `/config` when empty), `CLOAK_KEY` (required; same generation handling), `DATABASE_URL` (default `ecto://MYPOSTGRESUSER:MYPOSTGRESPASSWORD@postgresql/cannery`, required), `PORT` `4000`, `POOL_SIZE` `10`, `REGISTRATION` `invite`, `LOCALE` `en_US`, `ECTO_IPV6` `false`, `DISABLE_EMAIL` `""`, `SMTP_*`, `EMAIL_FROM`, `EMAIL_NAME` (all optional, empty default), `UPLOADS_PATH` `/config/uploads`, `TZ`.
volumes: `/config` required.
dependencies: `- name: postgresql` (exists: apps/postgresql ✅).

## 7. start.sh

1. `mkdir -p "${UPLOADS_PATH:-/config/uploads}"`.
2. If `SECRET_KEY_BASE` is empty, read or create `/config/secret_key_base` (via `/app/priv/random.sh` or `openssl rand -base64 48`); same for `CLOAK_KEY` in `/config/cloak_key` (via `cloak_key.sh`). Never overwrite existing files; do not echo the values.
3. Wait for DB (retry loop with `pg_isready` is not in base; use bash `/dev/tcp` against the host and port parsed from `DATABASE_URL`, bounded retries).
4. Run migrations (command UNVERIFIED; typical `bin/cannery eval "Cannery.ReleaseTasks.migrate"`; confirm in the upstream Dockerfile/entrypoint).
5. `exec /app/bin/cannery start` with `PHX_SERVER=true` if the release needs it (UNVERIFIED), binding 0.0.0.0 (UNVERIFIED how Cannery sets `ip`; the runtime.exs must be checked).

## 8. container-test.yaml

Narrowed per protocol exception (all three criteria hold: hard postgresql dependency, will not serve without DB, no sidecar primitive). Add the comment `# narrowed: requires external postgresql; full functional test not feasible in single-container suite`. Contents: `timeoutSeconds: 180`; `filePaths: - /app/bin/cannery`; `runners` for `test -x /app/bin/cannery`. The tcp probe on 4000 is kept only if the app opens the port before DB is up (it will not); so the automated port 4000 probe is replaced by the file check, and port 4000 is probed manually in the section 11 run against a throwaway postgresql (`curl -fsS http://localhost:4000/` against a running postgresql sidecar). Test runs with no env; required env is handled by start.sh generation, but `DATABASE_URL` default will not resolve.

## 9. Rootless and read-only-rootfs adaptations

- `/var/cannery/uploads` -> `/config/uploads` via `UPLOADS_PATH` (draft expects an extra PVC; one `/config` volume replaces it).
- Mix release writes `RELEASE_TMP` and the `RELEASE_COOKIE` file under `/tmp`; set `RELEASE_TMP=/tmp`, `RELEASE_COOKIE` generated in `/tmp` if unset (UNVERIFIED).
- Runs as UID 568; nothing writes to `/app`.

## 10. Risks, caveats and open questions

- Upstream Dockerfile unreviewed (404 on raw paths); entrypoint, migrate command and bind address are UNVERIFIED.
- Elixir/OTP version and asset toolchain UNVERIFIED; build may need network access to hex.pm and GitHub for esbuild/tailwind.
- `CLOAK_KEY` loss makes stored authenticator secrets unreadable; document backing up `/config`.
- Migrations on first start; need PostgreSQL reachable.
- Both archs compile; arm64 is untested.

## 11. Build and test steps

```sh
cd apps/cannery
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create cannery-probe-config
docker run --rm -d --name cannery-probe --read-only --tmpfs /tmp -v cannery-probe-config:/config cannery:1.5.9
docker logs -f cannery-probe
forgetool containers test --image cannery:1.5.9 --config ./apps/cannery/container-test.yaml
docker rm -f cannery-probe; docker volume rm cannery-probe-config
```
Step 3 uses a throwaway `postgresql` container on a shared network and `DATABASE_URL` pointing to it. Expected: migrations complete, then the Phoenix/Cowboy line `Running CanneryWeb.Endpoint with ... at 0.0.0.0:4000 (http)` (wording UNVERIFIED); port 4000 open. Without the DB the container may log connection retries; that only counts if the process stays alive.

## 12. PR checklist

- Branch `feat/add-cannery`; commit and PR title `feat(cannery): add new container`; target `main`.
- Fill the PR template; Notes include `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Untested: everything (build, migrations, runtime, arm64); the narrowed container test must be called out.
