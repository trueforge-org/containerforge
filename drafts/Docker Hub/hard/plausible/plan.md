# plausible — implementation plan
> Source: ./draft.md · Target: apps/plausible/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | v3.2.2 (latest GitHub release of plausible/analytics, 2026-11-23). Draft tag v2.0.0 is outdated. |
| Renovate | datasource=github-releases, depName=plausible/analytics, versioning=semver (tags are `vX.Y.Z`; strip `v` with extractVersion if the repo convention requires) |
| License | AGPL-3.0-only (LICENSE.md confirmed as GNU AGPL v3). |
| Source URL | https://github.com/plausible/analytics/ |
| Download | Source tarball for both arches: `https://github.com/plausible/analytics/archive/refs/tags/v${VERSION}.tar.gz`; compiled with `mix release plausible` (MIX_ENV `ce`). No binaries. |
| Checksum | None published. |
| Upstream Dockerfile reviewed | master: stage 1 `node:24.22.1-alpine3.23` (Node source only); stage 2 `hexpm/elixir:1.20.4-erlang-28.5.0.5-alpine-3.23.5` (musl!) runs `mix deps.get --only ce`, `npm install` in assets and tracker, `npm run deploy --prefix ./tracker`, `mix assets.deploy`, `mix phx.digest priv/static`, `mix download_country_database`, `mix sentry.package_source_code`, `mix release plausible`; final `alpine:3.23.5` with openssl ncurses libstdc++ libgcc ca-certificates, release in /app, `/entrypoint.sh` (verified: `run` -> `/app/bin/plausible start`; `db <x>` -> `/app/<x>.sh`), ENV `LISTEN_IP=0.0.0.0`, `DEFAULT_DATA_DIR=/var/lib/plausible`, `LANG=C.UTF-8`, EXPOSE 8000, USER 999. |
| Env vars | Confirmed from community-edition README: `BASE_URL`, `SECRET_KEY_BASE` (>=64 bytes, `openssl rand -base64 48`), `HTTP_PORT`, `HTTPS_PORT`. UNVERIFIED (not fetched): `DATABASE_URL`, `CLICKHOUSE_DATABASE_URL`, `TOTP_VAULT_KEY`, `LISTEN_IP`, `PORT`. |

## 2. Target layout

- `apps/plausible/Dockerfile` (multi-stage)
- `apps/plausible/docker-bake.hcl`
- `apps/plausible/settings.yaml`
- `apps/plausible/container-test.yaml`
- `apps/plausible/start.sh`
No `defaults/`, no `root/`; no DOWNSTREAM_CHANGES.md.

## 3. Base image

Final: `ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`. Build stage on `hexpm/elixir:<ver>-erlang-<ver>-ubuntu-<release>` (glibc build, since the upstream alpine/musl release does not run on glibc Ubuntu; a release built on ubuntu with the same glibc family as the final stage is required). Closest sibling: `apps/clickhouse`/`apps/postgresql` for dependencies; for source builds none exact.

## 4. Dockerfile

1. Stage `build`: `FROM hexpm/elixir:1.20.4-erlang-28.5.0.5-ubuntu-<noble|resolute>` (UNVERIFIED that an ubuntu variant of this exact pair exists; fallback: install Elixir/Erlang via apt/asdf in an ubuntu stage). `ARG VERSION`, `ENV MIX_ENV=ce NODE_ENV=production HEX_HOME=/tmp/hex MIX_HOME=/tmp/mix npm_config_cache=/tmp/npm`. apt: git build-essential python3 ca-certificates curl nodejs npm brotli (Node 24 per upstream; use a Node stage `COPY --from=node:24.22.1-bookworm-slim`).
2. Download and extract the `v${VERSION}` tarball, then the upstream build commands exactly as listed in section 1, ending with `mix release plausible --path /out`. Versions of Elixir/Node must be re-read from the tag's Dockerfile at port time (they change often); renovate comments not needed for them if copied from upstream.
3. Final stage: `FROM ghcr.io/trueforge-org/ubuntu:...`, `ARG VERSION`, `ARG TARGETARCH`, `USER root`, `apt-get install -y --no-install-recommends libssl3t64 libncurses6 libstdc++6 ca-certificates` (names UNVERIFIED for 26.04; check `ldd` on the release's erts).
4. `COPY --from=build /out /app`; licenses: copy `LICENSE.md` and `/app/priv` third-party notices to `/usr/share/licenses/plausible/`.
5. `ENV HOME=/config LANG=C.UTF-8 LISTEN_IP=0.0.0.0 DEFAULT_DATA_DIR=/config/data RELEASE_TMP=/tmp/release`.
6. `chown -R apps:apps /app`; `USER apps`; `COPY --chmod=0755 . /`; `EXPOSE 8000`; `VOLUME /config`.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "plausible" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=plausible/analytics versioning=semver
  default = "3.2.2"
}
variable "LICENSE" { default = "AGPL-3.0-only" }
variable "SOURCE" { default = "https://github.com/plausible/analytics/" }
```
Plus the four standard targets and `group "default"`. Run `docker buildx bake --print`.

## 6. settings.yaml

Header, `schema_version: 1`, `upstream_env_url: "https://github.com/plausible/analytics/"`.
- ports: `8000` tcp required false.
- env: `BASE_URL` default `http://localhost:8000` required false; `SECRET_KEY_BASE` default "" (start.sh generates and persists to /config when empty); `DATABASE_URL` default "" (UNVERIFIED name); `CLICKHOUSE_DATABASE_URL` default "" (UNVERIFIED name); `TOTP_VAULT_KEY` default "" (UNVERIFIED; generated if empty); `LISTEN_IP` default `0.0.0.0`; `TZ` default `Etc/UTC`.
- volumes: `/config` required true.
- dependencies: `postgresql` ✅, `clickhouse` ✅ (both hard).

## 7. start.sh

1. `mkdir -p /config/data /tmp/release`; export `RELEASE_TMP=/tmp/release`, `DEFAULT_DATA_DIR=/config/data`.
2. If `SECRET_KEY_BASE` empty: read `/config/secret_key_base`, else create with `openssl rand -base64 48` (chmod 600). Same for `TOTP_VAULT_KEY` (32-byte base64; UNVERIFIED format). Do not echo secrets.
3. If `DATABASE_URL`/`CLICKHOUSE_DATABASE_URL` empty: log a clear message and still start (will retry/crash by design); never write passwords to files or argv.
4. Run migrations each start: `/app/createdb.sh` and `/app/migrate.sh` (UNVERIFIED script names; the entrypoint maps `db <name>` to `/app/<name>.sh`, upstream compose uses `db createdb`, `db migrate`). Tolerate DB-not-ready by retrying a few times.
5. `exec /app/bin/plausible start` (listens on 0.0.0.0:8000 via `LISTEN_IP`).

## 8. container-test.yaml

Schema header; `timeoutSeconds: 180`. Plausible will not become healthy without PostgreSQL and ClickHouse. All three narrowing criteria hold (hard `dependencies:` on databases, will not start without them, no sidecar primitive), so use smoke assertions with the required comment: `# narrowed: requires external postgresql and clickhouse; full functional test not feasible in single-container suite`. Assertions: `tcp: - port: '8000'` (UNVERIFIED that the port opens before DB connect; if the release exits, drop to runners), `filePaths: /app/bin/plausible`, `/usr/share/licenses/plausible`, runner `test -x /app/bin/plausible`. Step 3 of the protocol (run + log parse) is mandatory with real DBs.

## 9. Rootless and read-only-rootfs adaptations

- Upstream writes: `/var/lib/plausible` (-> /config/data), release tmp/`RELEASE_TMP` (-> /tmp/release), erlang cookie/home (`HOME=/config`, or `RELEASE_COOKIE`; UNVERIFIED), `certbot` Let's Encrypt storage (CE only; not shipped: TLS is delegated to a proxy, so HTTP_PORT/HTTPS_PORT are not supported), GeoIP database is baked into the release at build.
- Draft: UID 1000, readOnlyRootFilesystem false; we use `USER apps` with read-only rootfs.

## 10. Risks, caveats and open questions

- Upstream final image is musl (alpine); a glibc Elixir release build is needed and not proven.
- ClickHouse is memory-hungry; both DBs required.
- Draft version v2.0.0 vs latest v3.2.2: tag may have changed envs and required Elixir versions.
- `mix download_country_database` needs network at build time (and may need a MaxMind/IP-to-location license acknowledgement: UNVERIFIED).
- Builds under QEMU for arm64 can segfault in Erlang (upstream uses `ERL_FLAGS` workaround).
- No unreleased tag/branch awareness: use tags, not master.
- Env names for DB URLs UNVERIFIED.

## 11. Build and test steps

```sh
cd apps/plausible
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker network create plausible-probe
# start postgresql and clickhouse sidecars from apps/postgresql and apps/clickhouse on that network, then:
docker run --rm -d --name plausible-probe --network plausible-probe --read-only --tmpfs /tmp \
  -v plausible-probe-config:/config -e BASE_URL=http://localhost:8000 \
  -e DATABASE_URL=... -e CLICKHOUSE_DATABASE_URL=... plausible:3.2.2
docker logs -f plausible-probe
forgetool containers test --image plausible:3.2.2 --config ./apps/plausible/container-test.yaml
docker rm -f plausible-probe; docker volume rm plausible-probe-config; docker network rm plausible-probe
```
Expected readiness: Phoenix endpoint "Running PlausibleWeb.Endpoint ... http://0.0.0.0:8000" style line (exact text UNVERIFIED) and port 8000 open, no migration errors.

## 12. PR checklist

- Branch `feat/add-plausible`; commit `feat(plausible): add new container`; PR template filled; Notes contains `🤖 This PR is AI generated.`
- CLA notice: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Untested: glibc release build, arm64, migrations, DB connectivity, env names, narrowed container test.
