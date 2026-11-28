# vikunja — implementation plan
> Source: ./draft.md · Target: apps/vikunja/ · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Upstream | https://github.com/go-vikunja/vikunja (Go API with the Vue frontend embedded), docs https://vikunja.io/docs/ |
| Latest stable | `v2.8.0` (tags seen: v2.7.0, v2.7.1, v2.8.0). Matches the draft's chart tag `2.8.0` |
| Renovate | `datasource=github-releases depName=go-vikunja/vikunja versioning=semver` |
| License | AGPL-3.0-or-later. `LICENSE` is the AGPLv3 text and `main.go` carries the "either version 3 of the License, or (at your option) any later version" header |
| amd64 asset | `https://github.com/go-vikunja/vikunja/releases/download/v2.8.0/vikunja-v2.8.0-linux-amd64-full.zip` (HTTP 200) |
| arm64 asset | `https://github.com/go-vikunja/vikunja/releases/download/v2.8.0/vikunja-v2.8.0-linux-arm64-full.zip` (HTTP 200) |
| Draft correction | The draft links `veans-v2.8.0-...` files. `veans` is a separate CLI shipped in the same release, not the server. The arm64 `.apk` link is also wrong. Use the `vikunja-...-linux-<arch>-full.zip` assets above |
| Zip content (amd64, inspected) | `vikunja-v2.8.0-linux-amd64` (65 MB binary), `config.yml.sample`, `LICENSE`, `vikunja-v2.8.0-linux-amd64.sha256` (`<hash>  vikunja-v2.8.0-linux-amd64`). The arm64 zip is expected to follow the same naming (UNVERIFIED: not downloaded) |
| Checksum source | No separate checksum asset on the GitHub release (the `.sha256` URL returns 404). Two options: the `.sha256` file inside the zip (integrity of the zip only, not authenticity), and a detached GPG signature `https://dl.vikunja.io/vikunja/v2.8.0/vikunja-v2.8.0-linux-<arch>-full.zip.sig` (UNVERIFIED: the signing key fingerprint was not looked up) |
| Upstream Dockerfile | Reviewed (`Dockerfile` at v2.8.0): `FROM scratch`, `WORKDIR /app/vikunja`, `ENTRYPOINT /app/vikunja/vikunja`, `EXPOSE 3456`, `USER 1000`, `ENV VIKUNJA_SERVICE_ROOTPATH=/app/vikunja/`, `VIKUNJA_DATABASE_PATH=/db/vikunja.db`, `GODEBUG=multipathtcp=0` (CVE mitigation comment) |
| Port | `3456/tcp` (default `service.interface` `:3456`) |
| Health endpoint | `GET /health` and `GET /api/v1/info` (`pkg/routes/routes.go`) |
| Config mechanism | viper with env prefix `VIKUNJA_` and `.` replaced by `_`, so `database.type` becomes `VIKUNJA_DATABASE_TYPE`. Config file `config.yml` is searched in `service.rootpath` |
| Env vars (verified keys in `pkg/config/config.go`) | `VIKUNJA_SERVICE_ROOTPATH`, `VIKUNJA_SERVICE_INTERFACE` (`:3456`), `VIKUNJA_SERVICE_PUBLICURL`, `VIKUNJA_SERVICE_SECRET` (random if empty, regenerated each start), `VIKUNJA_SERVICE_ENABLEREGISTRATION` (default true), `VIKUNJA_SERVICE_TIMEZONE` (default GMT), `VIKUNJA_DATABASE_TYPE` (default `sqlite`; also `postgres`/`mysql`), `VIKUNJA_DATABASE_PATH` (default `<rootpath>/vikunja.db`), `VIKUNJA_DATABASE_HOST` (default `localhost`), `VIKUNJA_DATABASE_USER`, `VIKUNJA_DATABASE_PASSWORD`, `VIKUNJA_DATABASE_DATABASE`, `VIKUNJA_DATABASE_SSLMODE` (default `disable`), `VIKUNJA_FILES_BASEPATH` (default `files`, resolved against the rootpath), `VIKUNJA_FILES_MAXSIZE`, `VIKUNJA_LOG_ENABLED`, `VIKUNJA_LOG_PATH` (default `<rootpath>/logs`), `VIKUNJA_KEYVALUE_TYPE` (default `memory`; `redis` for valkey), `VIKUNJA_REDIS_HOST` |
| Data paths | SQLite DB, uploaded files (`files/`) and logs, all relative to the rootpath |

## 2. Target layout

```
apps/vikunja/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```

No `defaults/`: Vikunja runs with zero config (SQLite default). `root/` is never used. No `DOWNSTREAM_CHANGES.md`: no other app builds `FROM` it (re-check with grep before the PR).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`

Why: a self-contained Go binary from release zips. The ubuntu base already provides `unzip`, `curl`, `ca-certificates`, `tzdata` and `jq`. Closest sibling: `apps/adguardhome-sync`; `apps/bazarr` shows the `unzip` pattern. Go is not compiled here because upstream ships the binary (the Go rule about build stages applies only when building from source).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH` (`amd64` / `arm64` match the asset names, so no mapping).
2. `USER root`; `ENV HOME=/config GODEBUG=multipathtcp=0` (keeps upstream's MPTCP mitigation).
3. One `RUN`:
   - `V="${VERSION#v}"`, `Z="vikunja-v${V}-linux-${TARGETARCH}-full.zip"`
   - `curl -fsSL -o /tmp/vikunja.zip "https://github.com/go-vikunja/vikunja/releases/download/v${V}/${Z}"`
   - `mkdir -p /tmp/vk /app/vikunja /usr/share/licenses/vikunja && unzip -q /tmp/vikunja.zip -d /tmp/vk`
   - Verify the in-zip checksum: `cd /tmp/vk && sha256sum -c "vikunja-v${V}-linux-${TARGETARCH}.sha256"`. This only proves the zip is intact. If maintainers want authenticity, add `gpg --verify` of the `.sig` once the key fingerprint is pinned (open question, section 10).
   - `install -m 0755 "/tmp/vk/vikunja-v${V}-linux-${TARGETARCH}" /app/vikunja/vikunja`
   - `cp /tmp/vk/LICENSE /usr/share/licenses/vikunja/LICENSE` and `cp /tmp/vk/config.yml.sample /app/vikunja/config.yml.sample` (reference only)
   - `chown -R apps:apps /app && chmod -R 755 /app && rm -rf /tmp/*`
4. `USER apps`; `COPY --chmod=0755 . /`; `EXPOSE 3456`; `VOLUME /config`; `WORKDIR /config`.
5. No apt packages.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "vikunja" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=go-vikunja/vikunja versioning=semver
  default = "2.8.0"
}
variable "LICENSE" { default = "AGPL-3.0-or-later" }
variable "SOURCE"  { default = "https://github.com/go-vikunja/vikunja" }
```

Standard targets from `apps/adguardhome-sync/docker-bake.hcl`: `docker-metadata-action`, `image` (args VERSION, source and licenses labels), `image-local`, `image-all` (amd64 + arm64), `group "default"`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

- Schema header, `schema_version: 1`, `upstream_env_url: "https://github.com/go-vikunja/vikunja"`.
- `ports`: `3456` / `tcp` / `required: false`.
- `env` (defaults equal what start.sh exports):
  - `TZ` / `Etc/UTC`
  - `VIKUNJA_SERVICE_ROOTPATH` / `/config`
  - `VIKUNJA_SERVICE_INTERFACE` / `:3456`
  - `VIKUNJA_SERVICE_PUBLICURL` / `""` (set to the external URL; needed for links and CORS)
  - `VIKUNJA_SERVICE_SECRET` / `""` (generated and persisted by start.sh when empty)
  - `VIKUNJA_SERVICE_ENABLEREGISTRATION` / `true`
  - `VIKUNJA_DATABASE_TYPE` / `sqlite`
  - `VIKUNJA_DATABASE_PATH` / `/config/vikunja.db`
  - `VIKUNJA_FILES_BASEPATH` / `/config/files`
  - `VIKUNJA_DATABASE_HOST`, `VIKUNJA_DATABASE_USER`, `VIKUNJA_DATABASE_PASSWORD`, `VIKUNJA_DATABASE_DATABASE` (empty, only for `postgres`)
  - `VIKUNJA_KEYVALUE_TYPE` / `memory`, `VIKUNJA_REDIS_HOST` / `""`
  - all `required: false`.
- `volumes`: `/config` / required true.
- `opt_dependencies`: `postgresql` ✅ (`apps/postgresql` exists), `valkey` ✅ (`apps/valkey` exists). Use the `opt_dependencies:` key, as in the sibling apps that have optional DBs. The draft marks both optional, so there is no hard `dependencies:` entry.

## 7. start.sh

```bash
#!/usr/bin/env bash
export VIKUNJA_SERVICE_ROOTPATH="${VIKUNJA_SERVICE_ROOTPATH:-/config}"
export VIKUNJA_DATABASE_PATH="${VIKUNJA_DATABASE_PATH:-/config/vikunja.db}"
export VIKUNJA_FILES_BASEPATH="${VIKUNJA_FILES_BASEPATH:-/config/files}"
export VIKUNJA_LOG_PATH="${VIKUNJA_LOG_PATH:-/tmp/vikunja-logs}"
export VIKUNJA_SERVICE_INTERFACE="${VIKUNJA_SERVICE_INTERFACE:-:3456}"
mkdir -p "$VIKUNJA_FILES_BASEPATH" "$(dirname "$VIKUNJA_DATABASE_PATH")" "$VIKUNJA_LOG_PATH"
# stable secret across restarts: generate once, never overwrite
if [ -z "${VIKUNJA_SERVICE_SECRET:-}" ]; then
  [ -s /config/.service_secret ] || (umask 077; head -c 48 /dev/urandom | base64 | tr -d '\n' > /config/.service_secret)
  VIKUNJA_SERVICE_SECRET="$(cat /config/.service_secret)"
  export VIKUNJA_SERVICE_SECRET
fi
cd /config
exec /app/vikunja/vikunja
```

- Idempotent; seeds only when missing; no writes to `/app`; logs go to `/tmp` (console logging stays on).
- Without the persisted secret, Vikunja regenerates a random one on every start and invalidates all sessions.
- Binds `:3456`, which is all interfaces.
- A secret kept only in `/config/.service_secret` stays out of the process list (it is exported into the environment, not passed as an argument).
- The database password is read from `VIKUNJA_DATABASE_PASSWORD` on every start (nothing is stored), so changing it works on existing data.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '3456'
http:
- port: '3456'
  path: /health
filePaths:
- /app/vikunja/vikunja
- /usr/share/licenses/vikunja/LICENSE
```

The test runs with no env, so it exercises the SQLite default. Postgres/valkey paths are not covered (see section 11 for a manual run). The DB-dependency narrowing does not apply: the DBs are optional, so full tests are used.

## 9. Rootless and read-only-rootfs adaptations

| Upstream behaviour | Remap |
| --- | --- |
| Rootpath `/app/vikunja/` (binary directory) | `VIKUNJA_SERVICE_ROOTPATH=/config`, so config lookup, DB and files live in `/config`; the binary lives in read-only `/app/vikunja` |
| DB at `/db/vikunja.db` (upstream image) | `/config/vikunja.db` |
| Uploads at `/app/vikunja/files` (draft's extra persistence) | `/config/files`, so no second volume |
| Logs at `<rootpath>/logs` | `/tmp/vikunja-logs` (ephemeral) |
| `/tmp` with mode 1777 and UID 1000 | tmpfs `/tmp` is provided at runtime; UID is 568 |
| Chart: UID 0, `NET_BIND_SERVICE` capability | Not needed: port 3456 is unprivileged. Run as `apps` with `readOnlyRootFilesystem` true |

## 10. Risks, caveats and open questions

- Authenticity of the download: only the in-zip hash is usable without extra tooling. Decide whether to pin the GPG key for `.sig`.
- UNVERIFIED: the binary is built with xgo (cgo for SQLite). Its glibc requirement must be satisfied by Ubuntu 26.04; the build-time run of `--version` is not in the plan, so the first run in step 3 is the check. If it fails with a musl or glibc error, switch to copying from `vikunja/vikunja:2.8.0` (but that image is `scratch`, with the same binary).
- UNVERIFIED: arm64 zip internals (file name pattern) are assumed to match amd64.
- `VIKUNJA_SERVICE_PUBLICURL` should be set behind a reverse proxy, and `cors.enable` requires it (config.go warns when it is missing).
- SQLite on a network filesystem can corrupt; recommend postgres for HA.
- The `veans` assets in the draft are the wrong product; make sure nobody copies those links.
- Vikunja also needs write access to `/tmp` for exports/imports (UNVERIFIED); the tmpfs covers that.

## 11. Build and test steps

```sh
cd apps/vikunja
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create vikunja-probe-config
docker run --rm -d --name vikunja-probe --read-only --tmpfs /tmp \
  -v vikunja-probe-config:/config vikunja:2.8.0
docker logs -f vikunja-probe        # expect a "Running migrations" step and a listening line, no fatal
docker exec vikunja-probe curl -fsS http://127.0.0.1:3456/health
forgetool containers test --image vikunja:2.8.0 --config ./apps/vikunja/container-test.yaml
docker restart vikunja-probe        # session secret must stay the same (/config/.service_secret unchanged)
docker rm -f vikunja-probe; docker volume rm vikunja-probe-config
```

Manual optional run against `apps/postgresql` with `VIKUNJA_DATABASE_TYPE=postgres` and its host/user/password/database env, and `VIKUNJA_KEYVALUE_TYPE=redis` plus `VIKUNJA_REDIS_HOST=valkey:6379`. Optionally repeat the build on `linux/arm64`. Expected readiness signal: the server listening on `:3456` (exact log text UNVERIFIED) and `/health` returning HTTP 200.

## 12. PR checklist

- Branch `feat/add-vikunja`; commit and PR title `feat(vikunja): add new container`; target `main`.
- Fill in `.github/PULL_REQUEST_TEMPLATE.md` completely; tick only what applies.
- `🤖 This PR is AI generated.` in the Notes section.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only they can sign; `license/cla` shows the status).
- State what was not tested (arm64, postgres, valkey, GPG verification of the zip, long-running use) and do not tick "Built container locally" unless it was.
- Pre-completion: bake print, image-local build, empty-`/config` read-only run, forgetool test, no weakened assertions, cleanup done.
