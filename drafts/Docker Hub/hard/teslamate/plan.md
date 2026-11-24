# teslamate — implementation plan
> Source: ./draft.md · Target: apps/teslamate/ · Difficulty: hard (Elixir release compiled from source, hard PostgreSQL dependency, MQTT broker needed) · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | `4.5.0` (tag/release `v4.5.0`, published 2026-11-17; same as draft image `teslamate/teslamate:4.5.0`). `main` has `VERSION` file `4.6.0-dev`, so pin the tag, not main. |
| Renovate | `datasource=github-releases depName=teslamate-org/teslamate versioning=semver` (tag has leading `v`, Dockerfile uses `v${VERSION}`). |
| License | AGPL-3.0 (GitHub API `spdx_id: AGPL-3.0`) -> `AGPL-3.0-only`. UNVERIFIED if the repo says "or later". |
| Source | https://github.com/teslamate-org/teslamate |
| Artifacts | The release has no assets (assets list empty). Compile from source on both arches (draft: compile/compile). |
| Checksum | Not applicable (git tag source). |
| Upstream Dockerfile reviewed | `https://github.com/teslamate-org/teslamate/blob/v4.5.0/Dockerfile`. Stage `builder`: `FROM elixir:1.20.4-otp-29`, Node 22 from NodeSource (plus `ca-certificates curl gnupg brotli`), `mix local.rebar --force && mix local.hex --force`, `ENV MIX_ENV=prod`, `WORKDIR /opt/app/elixir`, steps `mix deps.get`, `mix deps.compile`, `npm ci` in `assets/`, `mix assets.deploy`, `mix compile`, `mix release` to `/opt/built`, legal files to `/opt/legal`. Stage `app`: `FROM debian:trixie-slim`, apt `ca-certificates libodbc2 libsctp1 libssl3t64 libstdc++6 tini tzdata`, `ENV LANG=C.UTF-8 SRTM_CACHE=/opt/app/.srtm_cache HOME=/opt/app`, user `nonroot` UID 10000/GID 10001, `EXPOSE 4000`, `ENTRYPOINT ["tini","--","/bin/dash","/entrypoint.sh"]`, `CMD ["bin/teslamate","start"]`. |
| Upstream `entrypoint.sh` | Sets `ulimit -n` to `ULIMIT_MAX_NOFILE` (default 65536) when the current limit is higher; runs `bin/teslamate eval "TeslaMate.Release.wait_for_database_and_migrate()"`; then `exec "$@"`. |
| Env vars (docs.teslamate.org/docs/configuration/environment_variables) | Required: `ENCRYPTION_KEY`; `MQTT_HOST` unless `DISABLE_MQTT=true`; DB: `DATABASE_USER`, `DATABASE_PASS`, `DATABASE_NAME`, `DATABASE_HOST`, `DATABASE_PORT` (5432), `DATABASE_POOL_SIZE` (10), `DATABASE_TIMEOUT` (60000), `DATABASE_SSL` (false), `DATABASE_SSL_CA_CERT_FILE`, `DATABASE_SSL_SNI`, `DATABASE_IPV6` (false), `DATABASE_SOCKET_DIR`. Web: `VIRTUAL_HOST` (localhost), `URL_PATH` (/), `CHECK_ORIGIN` (false), `PORT` (4000), `HTTP_BINDING_ADDRESS` (blank = all). MQTT: `DISABLE_MQTT` (false), `MQTT_PORT` (1883), `MQTT_USERNAME`, `MQTT_PASSWORD`, `MQTT_TLS`, `MQTT_NAMESPACE`, `MQTT_HOME_ASSISTANT_DISCOVERY*`. Other: `TZ`, `DEFAULT_GEOFENCE`, `IMPORT_DIR` (./import), `TESLA_*` hosts, `POLLING_*`, `HTTP_POOL_*`, `ULIMIT_MAX_NOFILE` (65536), `NOMINATIM_PROXY`, `TOKEN`. |
| Ports | 4000/http web UI (upstream EXPOSE). |
| Dependencies | PostgreSQL (hard, `apps/postgresql` exists). The draft misses MQTT: `MQTT_HOST` is required unless `DISABLE_MQTT=true`; `apps/mosquitto` exists. |

## 2. Target layout

```
apps/teslamate/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```
No defaults/ (no seeded config files). No root/. No DOWNSTREAM_CHANGES.md.

## 3. Base image

- Final: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`.
- Builder: `FROM elixir:1.20.4-otp-29 AS builder` (the exact image upstream uses; Debian trixie, glibc, multi-arch). The release bundles ERTS built against Debian trixie glibc/OpenSSL, run on Ubuntu 26.04 (newer glibc, so compatible; UNVERIFIED OpenSSL 3 soname match, `libssl3t64` is also what upstream installs). No ContainerForge Elixir base exists.
- Closest siblings: `apps/it-tools` (builder + final stage with npm assets), `apps/postgresql` for the dependency.

## 4. Dockerfile

1. Builder stage: copy the upstream steps, but fetch source via `ADD https://github.com/teslamate-org/teslamate.git#v${VERSION} /opt/app/elixir`. Install Node 22 from NodeSource (needs `curl gnupg brotli ca-certificates`), `mix local.rebar --force && mix local.hex --force`, `ENV MIX_ENV=prod`, `mix deps.get --only prod`, `mix deps.compile`, `npm ci --prefix assets`, `mix assets.deploy`, `mix compile`, `mix release --path /opt/built`; keep `HOME`/caches in `/tmp` (`ENV HEX_HOME=/tmp/hex MIX_HOME=/tmp/mix npm_config_cache=/tmp/npm`).
2. Final stage: `ARG VERSION`, `USER root`; apt (only packages missing in the base, no recommends): `ca-certificates libodbc2 libsctp1 libssl3t64 libstdc++6 tini tzdata`; `rm -rf /var/lib/apt/lists/*`.
3. `COPY --from=builder /opt/built/ /app/teslamate/`; licenses `COPY --from=builder /opt/legal/ /usr/share/licenses/teslamate/` (upstream puts them in `/usr/share/doc/teslamate/`).
4. `chown -R apps:apps /app && chmod -R 755 /app` (release is read-only at runtime).
5. `ENV LANG=C.UTF-8 HOME=/config SRTM_CACHE=/tmp/srtm_cache RELEASE_TMP=/tmp/release PORT=4000`, `EXPOSE 4000`, `VOLUME /config`, `COPY --chmod=0755 . /`, final `USER apps` and `COPY --chmod=0755 . /`.
6. `RELEASE_TMP` and a writable release temp dir are needed because mix releases write `vm.args`/`sys.config` copies at start; UNVERIFIED for this release, verify with `--read-only`.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "teslamate" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=teslamate-org/teslamate versioning=semver
  default = "4.5.0"
}
variable "LICENSE" { default = "AGPL-3.0-only" }
variable "SOURCE"  { default = "https://github.com/teslamate-org/teslamate" }
```
Standard four targets (`docker-metadata-action`, `image`, `image-local`, `image-all` amd64+arm64), `group "default" { targets = ["image-local"] }`. Run `docker buildx bake --print`. Dockerfile uses `v${VERSION}` for the tag.

## 6. settings.yaml

Header + `schema_version: 1`, `upstream_env_url: "https://github.com/teslamate-org/teslamate"`.
- ports: `4000` tcp `required: false`.
- env (names exactly as upstream): `TZ` `Etc/UTC`; `DATABASE_HOST` `postgresql` (required true); `DATABASE_PORT` `5432`; `DATABASE_NAME` `teslamate` (required true); `DATABASE_USER` `teslamate` (required true); `DATABASE_PASS` `""` (required true: no safe default; start.sh exits with a clear message when empty, see below, so give it a placeholder default like the postgresql sibling `MYPOSTGRESPASSWORD`); `ENCRYPTION_KEY` `""` (required true; start.sh generates and persists one in `/config` when unset, so non-empty requirement is met by generation); `MQTT_HOST` `mosquitto`; `MQTT_PORT` `1883`; `DISABLE_MQTT` `false`; `VIRTUAL_HOST` `localhost`; `CHECK_ORIGIN` `false`; `PORT` `4000`; `TESLA_API_HOST`/`POLLING_*` are not listed (leave to upstream defaults).
- volumes: `/config` required true (holds the generated encryption key).
- dependencies: `postgresql` ✅ (apps/postgresql exists), `mosquitto` ✅ (apps/mosquitto exists; skippable with `DISABLE_MQTT=true`). Grafana is a separate upstream service, not an apps/ dependency.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail
mkdir -p /tmp/srtm_cache /tmp/release /config
if [ -z "${ENCRYPTION_KEY:-}" ]; then
  [ -s /config/encryption_key ] || { umask 077; head -c 48 /dev/urandom | base64 | tr -d '\n' > /config/encryption_key; echo "Generated ENCRYPTION_KEY in /config/encryption_key; keep it with your database backup" >&2; }
  export ENCRYPTION_KEY="$(cat /config/encryption_key)"
fi
ulimit -n "${ULIMIT_MAX_NOFILE:-65536}" 2>/dev/null || true
cd /app/teslamate
/app/teslamate/bin/teslamate eval "TeslaMate.Release.wait_for_database_and_migrate()"
exec /usr/bin/tini -- /app/teslamate/bin/teslamate start
```
Idempotent; nothing written to `/app`; `HTTP_BINDING_ADDRESS` left unset so Phoenix binds all interfaces (upstream: blank = all). The DB password stays in the environment, not in files or argv. Migrations run on every start (as upstream). The `ulimit` handling mirrors upstream (upstream lowers an excessive limit; verify the semantic when implementing).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
# narrowed: requires external postgresql; full functional test not feasible in single-container suite
timeoutSeconds: 120
tcp:
- port: '4000'
filePaths:
- /app/teslamate/bin/teslamate
- /start.sh
```
The tcp 4000 probe is the settings.yaml port. Risk: the app blocks in `wait_for_database_and_migrate()` with no DB (the port never opens). Per the protocol's DB exception (all three criteria hold: hard postgresql dependency, will not serve without it, no sidecar primitives), if the probe cannot pass in CI, keep only the file assertions plus a log-based check if the schema allows (UNVERIFIED), never a no-op. The manual step 3 run must show "waiting for database" retries with the process alive, which counts as readiness under the exception.

## 9. Rootless and read-only-rootfs adaptations

- Upstream already runs as `nonroot` UID 10000; ContainerForge uses `apps`. Draft chart: UID 568, readOnlyRootFilesystem false; this plan runs with a read-only rootfs.
- Write paths: `HOME` -> `/config`; `SRTM_CACHE` (default `/opt/app/.srtm_cache`) -> `/tmp/srtm_cache`; Erlang release temp (`RELEASE_TMP`) -> `/tmp/release`; `IMPORT_DIR` default `./import` (relative to cwd `/app/teslamate`, read-only) is not used unless the user mounts and sets `IMPORT_DIR=/config/import`. Erlang cookie file (`~/.erlang.cookie`) goes to `/config` via `HOME`, or set `RELEASE_COOKIE` (UNVERIFIED which the release uses).
- No extra persistence beyond `/config` (draft: none; database is external).

## 10. Risks, caveats and open questions

- Heavy Elixir/npm build; arm64 native build is slow (hours under QEMU).
- External PostgreSQL required; MQTT broker required unless disabled; a Tesla account and tokens are entered in the web UI after first start. Grafana dashboards are a separate stack.
- `ENCRYPTION_KEY` loss makes stored tokens unreadable; generated keys live only in `/config`.
- Glibc/OpenSSL compatibility of a Debian-trixie-built release on Ubuntu 26.04 is expected but UNVERIFIED.
- Single-container tests cannot cover the app (DB exception).
- No musl, GPU or privileged blockers.

## 11. Build and test steps

```sh
cd apps/teslamate
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker network create teslamate-probe
docker run -d --name teslamate-probe-db --network teslamate-probe -e POSTGRES_USER=teslamate -e POSTGRES_PASSWORD=probe -e POSTGRES_DB=teslamate ghcr.io/trueforge-org/postgresql:<tag>
docker run --rm -d --name teslamate-probe --network teslamate-probe --read-only --tmpfs /tmp -v teslamate-probe-config:/config -e DATABASE_HOST=teslamate-probe-db -e DATABASE_USER=teslamate -e DATABASE_PASS=probe -e DATABASE_NAME=teslamate -e DISABLE_MQTT=true teslamate:4.5.0
docker logs -f teslamate-probe
forgetool containers test --image teslamate:4.5.0 --config ./apps/teslamate/container-test.yaml
docker rm -f teslamate-probe teslamate-probe-db; docker volume rm teslamate-probe-config; docker network rm teslamate-probe
```
Also run once without a database to confirm the retry-and-stay-alive behaviour. Expected: migrations run, Phoenix starts, `curl -f localhost:4000/` answers (redirect to sign-in acceptable).

## 12. PR checklist

- Branch `feat/add-teslamate`; commit and PR title `feat(teslamate): add new container`; target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`; Notes contain `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Untested (planning only): the Elixir build, glibc/OpenSSL compatibility, read-only release temp handling, DB and MQTT wiring, arm64. Note the narrowed container test in the PR. Do not tick "Built container locally" unless done.
