# gitlab.com/shibaobun/cannery (source repo, tags 1.5.8 and 1.5.9)

Source URL(s) + fetch date:
- https://gitlab.com/shibaobun/cannery · fetched 2026-11-26 (via tags page and raw files)
- https://gitlab.com/shibaobun/cannery/-/raw/1.5.9/README.md · fetched 2026-11-26
- https://gitlab.com/shibaobun/cannery/-/raw/1.5.9/LICENSE.md · fetched 2026-11-26
- https://gitlab.com/shibaobun/cannery/-/raw/1.5.9/mix.exs · fetched 2026-11-26
- https://gitlab.com/shibaobun/cannery/-/raw/1.5.9/.tool-versions · fetched 2026-11-26
- https://gitlab.com/shibaobun/cannery/-/raw/1.5.9/config/runtime.exs · fetched 2026-11-26
- https://gitlab.com/shibaobun/cannery/-/raw/1.5.9/Dockerfile · fetched 2026-11-26
- https://gitlab.com/shibaobun/cannery/-/raw/1.5.8/Dockerfile (draft's tag) · fetched 2026-11-26
- https://gitlab.com/shibaobun/cannery/-/raw/1.5.9/priv/docker-entrypoint.sh · fetched 2026-11-26
- https://gitlab.com/shibaobun/cannery/-/tags · fetched 2026-11-26
- Raw `main/README.md` returned 404 (not a failure of the project; the 1.5.9 tag works).

## What it is
"Self-hosted firearm tracker website" to track ammo, guns, components and containers, with range-day staging and shot records. Phoenix LiveView app (Elixir) on PostgreSQL. Image `shibaobun/cannery` (Docker Hub).

## Versions and tags
- Tags page (2026-11-26): 1.5.10 (Nov 26, pipeline running), 1.5.9 (Nov 22, passed), 1.5.8 (Nov 19, passed), 1.5.7 (Nov 13), 1.5.6 (Nov 11). No release assets or binaries listed for any tag.
- mix.exs at 1.5.9: `version: "1.5.9"`.
- Newer tag 1.5.10 exists; plan.md pins 1.5.9 (not changed here).
- Asset/archive pattern: source tarball `https://gitlab.com/shibaobun/cannery/-/archive/${VERSION}/cannery-${VERSION}.tar.gz` (direct archive, not fetched). Source-only project; compile both arches.

## Install / build steps (from upstream Dockerfile, 1.5.9 and 1.5.8 identical in shape)
Multi-stage:
1. Stage `node`: `FROM node:26.13.1-alpine3.24`.
2. Stage `build`: `FROM hexpm/elixir:1.20.5-erlang-29.1.2-alpine-3.24.3`. Copies `/usr/local/` from node stage. apk installs `build-base git python3 libstdc++` (`--no-cache`). `npm install -g npm@11.20.0`. WORKDIR `/app`. `mix local.hex --force` (Hex 2.6.0). Installs rebar3 3.28.0 from GitHub releases with SHA-512 check. `ENV MIX_ENV=prod`. COPY `mix.exs mix.lock` to `./`, then `config` and `vendor` (vendor is required: cloak and cloak_ecto are local path deps). `mix do deps.get, deps.compile`. COPY `assets/package.json` and `assets/package-lock.json`; `npm --prefix ./assets ci --progress=false --no-audit --loglevel=error`. COPY `lib priv assets`. `mix do phx.digest, gettext.extract`. `mix do assets.deploy, compile, release`. (`COPY rel rel` commented out.)
3. Stage `app`: `FROM alpine:latest`. `apk upgrade --no-cache`; apk installs `bash ca-certificates openssl libssl3 libcrypto3 libgcc libstdc++ ncurses-libs su-exec`. Symlink `/usr/lib/libc.so` -> `/lib/ld-musl-$(uname -m).so.1` (Vix NIF links the unversioned name). WORKDIR `/app`. `chown nobody:nobody /app`. `ENV MIX_ENV=prod UPLOADS_PATH=/var/cannery/uploads HOME=/app`. COPY from build: `/app/_build/prod/rel/cannery` -> `./` and `/app/priv` -> `/app/priv` (owned nobody:nobody). chmod 755 on `priv/random.sh`, `priv/cloak_key.sh`, `priv/docker-entrypoint.sh`. `ENTRYPOINT ["/app/priv/docker-entrypoint.sh"]`, `CMD ["bin/cannery", "start"]`. No EXPOSE, no VOLUME, no USER (entrypoint drops privileges).

Upstream runtime is **Alpine/musl**, not glibc. plan.md builds on Ubuntu 26.04 (glibc). That is a deliberate deviation from upstream and must be built and tested on its own terms.

## Entrypoint script (priv/docker-entrypoint.sh, 1.5.9)
```
#!/bin/sh
set -eu
dir="${UPLOADS_PATH:-/var/cannery/uploads}"
mkdir -p "${dir}/tmp"
chown -R nobody:nobody "${dir}"
exec su-exec nobody:nobody "$@"
```
Creates `${UPLOADS_PATH}/tmp`, chowns uploads to nobody, then drops privileges. The rootless port needs no chown or su-exec: create `${UPLOADS_PATH}` and `${UPLOADS_PATH}/tmp` directly.

## Helper scripts (priv/)
- `priv/random.sh`: generates SECRET_KEY_BASE. Documented run: `docker run -it shibaobun/cannery /app/priv/random.sh`.
- `priv/cloak_key.sh`: generates CLOAK_KEY. Documented run: `docker run --rm shibaobun/cannery /app/priv/cloak_key.sh`.
Script bodies not fetched.

## Mix project facts (mix.exs, 1.5.9)
- `elixir: "1.20.5"` (exact pin).
- Deps: phoenix ~> 1.8.5, phoenix_live_view ~> 1.2, phoenix_ecto ~> 4.4, esbuild ~> 0.8 and tailwind ~> 0.2 (dev-only runtime), cloak (local path `vendor/cloak`, override), cloak_ecto (local `vendor/cloak_ecto`), ecto ~> 3.14.3, ecto_sql ~> 3.6, postgrex >= 0.0.0, heroicons (GitHub `tailwindlabs/heroicons`, tag v2.2.0, sparse, app: false, compile: false, depth 1). Heroicons therefore needs GitHub network access at build time.
- No `releases` key in project; OTP app `mod: {Cannery.Application, []}`; extra apps `:logger :runtime_tools :os_mon :crypto`.
- Aliases: `assets.build` (tailwind + esbuild), `assets.deploy` (minified tailwind + esbuild, then phx.digest), `assets.setup`, `ecto.setup`, `setup`, `test`, `format.all`.

## .tool-versions (1.5.9)
`erlang 29.1.2`, `elixir 1.20.5-otp-29`, plus a Node entry.

## Runtime configuration (config/runtime.exs, 1.5.9)
| Variable | Default | Required |
|---|---|---|
| HOST | none | **Yes** in all envs; raises "No hostname set!" if missing. Used as external URL (prod endpoint url scheme https, port 443) |
| SECRET_KEY_BASE | none | **Yes** in prod; raises if missing |
| CLOAK_KEY | none | **Yes** in prod; must base64-decode to exactly 32 bytes ("CLOAK_KEY must be 32 random bytes, base64-encoded") |
| DATABASE_URL | `ecto://postgres:postgres@cannery-db/cannery` (non-test) | No |
| PORT | `4000` (non-test) | No |
| POOL_SIZE | `10` (not applied in test) | No |
| ECTO_IPV6 | unset; `"true"` gives `[:inet6]` | No |
| REGISTRATION | `invite` (dev/prod) | No; `public` opens sign-up |
| LOCALE | `en_US` | No; README lists `en_US`, `de`, `fr`, `es` |
| UPLOADS_PATH | prod `/var/cannery/uploads`; dev `../uploads` | No |
| DISABLE_EMAIL | unset | No; `true` or `1` disables mail |
| PHX_SERVER | unset | Presence only: if set at all, `CanneryWeb.Endpoint` server is true |
| SHIBAO_MODE | unset | Enabled only when `"true"` |
| DNS_CLUSTER_QUERY | nil | No |
| SMTP_HOST, SMTP_USERNAME, SMTP_PASSWORD | none | Set all three or none (README); SMTP_PORT 587, SMTP_SSL false, EMAIL_FROM `no-reply@HOST`, EMAIL_NAME "Cannery" (README) |

HTTP endpoint: `ip` is `{0,0,0,0,0,0,0,0}` (IPv6 any) in prod, `{0,0,0,0}` in dev/test. Not loopback. Migrations: prod sets `Cannery.Application` `automigrate: true`, so migrations run at app start; no separate migrate command is needed.

## README (1.5.9) summary
- Image `shibaobun/cannery`; deployed via example `docker-compose.yml` plus `deploy/` dir; Caddy preferred (TCP 80/443, UDP 443); app must sit behind a reverse proxy; listens on 4000 (`expose: "4000"` for proxy in same compose network).
- Required: HOST, SECRET_KEY_BASE (server will not start without it), CLOAK_KEY (32 random bytes base64). Optional list above.
- Uploads: `UPLOADS_PATH` must be outside public static files and shared by all app containers. Container creates the dir at startup and assigns it to app user. Compose bind-mounts `./cannery/uploads`.
- First created user is admin.
- Database: PostgreSQL. README does not describe app migrations (only PostgreSQL major-version upgrades via pgautoupgrade).
- Backup: back up `CLOAK_KEY` (changed value makes authenticator secrets unreadable) and the uploads directory.
- Licence: AGPLv3 "or any later version" (per README).

## LICENSE.md (1.5.9)
GNU Affero General Public License, Version 3 (19 November 2007). The text itself does not state "only" or "or later"; README states "AGPLv3 or later". SPDX `AGPL-3.0-or-later` is supported.

## Dockerfile differences 1.5.8 vs 1.5.9
Both fetched; same stages and base images (node 26.13.1-alpine3.24, hexpm/elixir 1.20.5-erlang-29.1.2-alpine-3.24.3, alpine:latest).

## Gotchas
- Upstream Dockerfile is Alpine/musl; plan.md uses Ubuntu 26.04 glibc (see plan corrections).
- Entrypoint and su-exec drop privileges; not applicable to a non-root image.
- Heroicons is a git dep fetched from GitHub at build time.
