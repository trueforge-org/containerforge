# chronograf — implementation plan
> Source: ./draft.md · Target: apps/chronograf/ · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | Pin `1.11.7` (released 2026-11-04; draft pins the same). `1.11.8` was published on 2026-11-25 and its amd64/arm64 debs and `.asc` files return HTTP 200; see section 10. The TrueCharts chart uses the rolling `chronograf:latest`. |
| Git tag format | `1.11.7` (no `v` prefix), verified with `git ls-remote --tags` |
| Renovate | `datasource=github-releases depName=influxdata/chronograf` (default semver versioning is fine) |
| License | `AGPL-3.0-or-later`. The repo `LICENSE` says "GNU Affero General Public License ... version 3 ... or (at your option) any later version". |
| Source (`SOURCE`, `upstream_env_url`) | https://github.com/influxdata/chronograf |
| amd64 download | https://dl.influxdata.com/chronograf/releases/chronograf_1.11.7_amd64.deb (HTTP 200) |
| arm64 download | https://dl.influxdata.com/chronograf/releases/chronograf_1.11.7_arm64.deb (HTTP 200) |
| Checksum / signature | Detached GPG signature `<deb>.asc` next to each deb (HTTP 200). Verified locally: key `24C975CBA61A024EE1B631787C3D57159FC2F927` (the key used by the upstream Dockerfile) gives a good signature for the amd64 deb. No `.sha256` file exists (404). SHA256 seen on 2026-11-23: amd64 `ebd301638246d5cfcfe2e879b14975814e52f703b869758e140ae1e0b6fddad4`, arm64 `0f64b8f617d74c0ee55c67a6c49496c907300e719d1ed8942921f3bbc5fb0aa8` (for reference only, do not hard-code them because renovate bumps would break). |
| Upstream Dockerfile | Reviewed: https://github.com/influxdata/influxdata-docker/blob/master/chronograf/1.11/Dockerfile. `debian:bookworm-slim`, installs the deb after `gpg --verify`, `EXPOSE 8888`, `VOLUME /var/lib/chronograf`, `ENTRYPOINT /entrypoint.sh`, `CMD chronograf`. |
| Upstream entrypoint | Sets `BOLT_PATH=${BOLT_PATH:-/var/lib/chronograf/chronograf-v1.db}`, then drops to the `chronograf` user with `setpriv` unless already non-root. We skip all of that (we are already `apps`). |
| Deb contents (inspected with `dpkg-deb -c`) | `/usr/bin/chronograf`, `/usr/bin/chronoctl`, `/usr/share/chronograf/{canned,protoboards,resources}/`, `/usr/lib/chronograf/scripts/{chronograf.service,init.sh}`, `/etc/logrotate.d/chronograf`, `/usr/share/doc/chronograf/changelog.gz`. No LICENSE file inside the deb. |
| Env vars (https://docs.influxdata.com/chronograf/v1/administration/config-options/) | `HOST` (default `0.0.0.0`), `PORT` (`8888`), `BOLT_PATH` (default `./chronograf-v1.db`), `CANNED_PATH` (`/usr/share/chronograf/canned`), `RESOURCES_PATH` (`/usr/share/chronograf/resources`), `INFLUXDB_URL`, `KAPACITOR_URL`, `BASE_PATH`, `LOG_LEVEL` (`info`; `debug`/`info`/`error`), `REPORTING_DISABLED`, `TLS_CERTIFICATE`, `TLS_PRIVATE_KEY`, `CUSTOM_AUTO_REFRESH`. CLI flags win over env vars. |
| Port | 8888/tcp (web UI, HTTP) |
| Maintenance mode claim in the draft | UNVERIFIED: neither the releases page nor the README mentions maintenance mode. Recent releases (1.11.x) are active (Go and Flux upgrades, security fixes in 1.11.1). |

## 2. Target layout

```
apps/chronograf/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```

- No `defaults/`, `etc/`, `scripts/` or `health/`: Chronograf creates its BoltDB file itself on first start and needs no seeded config.
- No `root/` directory.
- No `DOWNSTREAM_CHANGES.md`: no other app uses `chronograf` as a `FROM` base (checked `apps/`).
- No sibling Dockerfile uses a `.deb` extraction. Closest pattern: `apps/adguardhome-sync` (prebuilt binary on ubuntu).

## 3. Base image

```
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454
```

The upstream binary is a statically linked Go program from a vendor deb, so the plain ubuntu base is enough. `curl`, `gnupg`, `dirmngr`, `ca-certificates` and `dpkg` (for `dpkg-deb -x`) are already in the base, so no `apt-get install` is needed. Closest sibling: `apps/adguardhome-sync`. The go-runtime rules apply only in spirit: no Go compile happens, we ship the vendor binary, and no Go cache is written.

## 4. Dockerfile

1. `FROM` line as in section 3, then `ARG VERSION`, `ARG TARGETARCH` (values `amd64` / `arm64` match the deb file names exactly, so no arch mapping is needed).
2. `USER root` for the install step only.
3. `ENV HOME=/config BOLT_PATH=/config/chronograf-v1.db` (persistent DB in `/config`, upstream default would be the read-only working dir). `CANNED_PATH` and `RESOURCES_PATH` keep their upstream defaults under `/usr/share/chronograf` and are not set.
4. One `RUN`:
   - `mkdir -p /tmp/chronograf && cd /tmp/chronograf`
   - download `chronograf_${VERSION}_${TARGETARCH}.deb` and `.deb.asc` from `https://dl.influxdata.com/chronograf/releases/` with `curl -fsSLO`
   - `export GNUPGHOME=$(mktemp -d)`, `gpg --batch --keyserver hkps://keyserver.ubuntu.com --recv-keys 24C975CBA61A024EE1B631787C3D57159FC2F927` (same fallback pattern as `apps/ubuntu`: retry with `hkps://keys.openpgp.org`), then `gpg --batch --verify <deb>.asc <deb>` (fail the build on error)
   - `dpkg-deb -x chronograf_${VERSION}_${TARGETARCH}.deb /tmp/chronograf/root`
   - `install -m 0755 /tmp/chronograf/root/usr/bin/chronograf /app/chronograf` (binary lives in `/app`); optionally also `chronoctl` to `/app/chronoctl`
   - `mkdir -p /usr/share/chronograf && cp -a /tmp/chronograf/root/usr/share/chronograf/. /usr/share/chronograf/` (canned, protoboards and resources stay at the paths the binary defaults to; read-only at runtime)
   - license: `mkdir -p /usr/share/licenses/chronograf` and download `https://raw.githubusercontent.com/influxdata/chronograf/${VERSION}/LICENSE` and `.../agpl-3.0.md` (the deb has no license file); `chown -R apps:apps /app`, `chmod -R 755 /app`
   - clean up `/tmp/chronograf` and `$GNUPGHOME`
5. `COPY --chmod=0755 . /` (copies `start.sh` through the allow-list in `include/.dockerignore`).
6. `EXPOSE 8888`, `VOLUME /config`.
7. Final `USER apps` (not `apps:apps`).

No apt packages are installed, so there is nothing to pin against `VERSION`. The deb version equals `VERSION`, which keeps image and tag aligned.

## 5. docker-bake.hcl

- `APP` = `chronograf`
- `VERSION`:
  ```hcl
  // renovate: datasource=github-releases depName=influxdata/chronograf
  default = "1.11.7"
  ```
- `LICENSE` = `AGPL-3.0-or-later`
- `SOURCE` = `https://github.com/influxdata/chronograf`
- Targets copied from `apps/adguardhome-sync/docker-bake.hcl`: `docker-metadata-action`, `image` (args `VERSION`, labels `org.opencontainers.image.source` and `.licenses`), `image-local` (`type=docker`, tag `${APP}:${VERSION}`), `image-all` (`linux/amd64`, `linux/arm64`), and `group "default" { targets = ["image-local"] }`.
- Validate with `cd apps/chronograf && docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/influxdata/chronograf"
ports:
  - port: 8888
    protocol: tcp
    required: false
env:  # only variables Chronograf reads (verified in the config-options docs)
  - name: BOLT_PATH
    default: "/config/chronograf-v1.db"
    required: false
  - name: HOST
    default: "0.0.0.0"
    required: false
  - name: PORT
    default: "8888"
    required: false
  - name: LOG_LEVEL
    default: "info"
    required: false
  - name: INFLUXDB_URL
    default: ""
    required: false
  - name: KAPACITOR_URL
    default: ""
    required: false
  - name: BASE_PATH
    default: ""
    required: false
  - name: REPORTING_DISABLED
    default: "true"
    required: false
  - name: CANNED_PATH
    default: "/usr/share/chronograf/canned"
    required: false
  - name: RESOURCES_PATH
    default: "/usr/share/chronograf/resources"
    required: false
  - name: TLS_CERTIFICATE
    default: ""
    required: false
  - name: TLS_PRIVATE_KEY
    default: ""
    required: false
  - name: CUSTOM_AUTO_REFRESH
    default: ""
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

Dependencies: Chronograf visualises an external InfluxDB server. `apps/` has no `influxdb` container, so there is no `dependencies:` entry to mark (it is optional: the UI starts without a data source). `REPORTING_DISABLED=true` is our default choice (privacy), exported in `start.sh`. The OAuth/auth variables (`TOKEN_SECRET`, `GENERIC_*`, ...) are UNVERIFIED in this pass, so they are not listed.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

export BOLT_PATH="${BOLT_PATH:-/config/chronograf-v1.db}"
export HOST="${HOST:-0.0.0.0}"
export PORT="${PORT:-8888}"
export REPORTING_DISABLED="${REPORTING_DISABLED:-true}"

mkdir -p "$(dirname "${BOLT_PATH}")"   # /config is empty on first start; the DB file is created by chronograf

exec /app/chronograf
```

- Idempotent: only creates the directory, never overwrites the DB.
- No writes to `/app`; BoltDB goes to `/config`; no cache dirs are needed (if `chronograf` is found to write temp files, set `TMPDIR=/tmp`).
- Binds `0.0.0.0` (also the upstream default).
- `exec` hands PID over for signal propagation. Env values are passed through the environment, not the command line, so secrets stay out of the process list.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '8888'
http:
- port: '8888'
  path: /
filePaths:
- /app/chronograf
- /usr/share/chronograf/canned/docker.json
- /usr/share/licenses/chronograf/LICENSE
```

- Covers the only port in `settings.yaml`. The test runs without env vars, which is fine because every variable has a default.
- UNVERIFIED: the exact status code of `GET /` (Chronograf normally serves the SPA or redirects). If `forgetool` demands 200 and gets a redirect, add `statusCode` after checking with `curl -i` on the running container; do not weaken the assertion, only match the real value.
- `timeoutSeconds: 120` copies `apps/luanti`. The forgetool schema enforces a 180-second minimum, so lower values have no effect.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
|---|---|
| `/var/lib/chronograf/chronograf-v1.db` (upstream `VOLUME`) | `BOLT_PATH=/config/chronograf-v1.db` |
| working dir `./chronograf-v1.db` (binary default) | covered by `BOLT_PATH` |
| `/usr/share/chronograf/*` | read-only, only read |
| any temp files | `/tmp` (tmpfs in the test run) |

Draft security expectations reconciled: the chart runs as UID 0 with a writable rootfs. We deviate on purpose: UID 568 (`apps`), `readOnlyRootFilesystem: true`, not privileged. Extra persistence `/var/lib/chronograf` is mapped to `/config` (document in the PR that existing chart data must be moved from `/var/lib/chronograf/chronograf-v1.db` to `/config/chronograf-v1.db`). The upstream `setpriv` drop is not needed.

## 10. Risks, caveats and open questions

- Chronograf needs an InfluxDB data source (or `INFLUXDB_URL`) before it is useful; the container itself starts without one.
- `1.11.8` came out on 2026-11-25. When implementing, either take it (bake `VERSION`, URLs and tags in this plan change together; re-check the signature and deb layout) or keep 1.11.7 and let Renovate bump it. Section 1 deb contents and checksums were inspected for 1.11.7 only.
- Maintenance-mode claim from the draft is UNVERIFIED (see section 1).
- Chart uses `latest` while the image will be pinned to `1.11.7`; Renovate will bump it.
- Keyserver availability during the build (GPG key fetch). Mitigation: retry the second keyserver; if both fail, fail the build instead of skipping verification.
- UNVERIFIED: whether the binary writes anything else besides the BoltDB (check with `--read-only` run).
- No blockers: glibc/static Go binary, arm64 deb exists.

## 11. Build and test steps

```sh
cd apps/chronograf
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create chronograf-probe-config
docker run --rm -d --name chronograf-probe --read-only --tmpfs /tmp \
  -v chronograf-probe-config:/config chronograf:1.11.7
docker logs -f chronograf-probe        # expect a "Serving chronograf at http://[::]:8888" style line (UNVERIFIED exact text) and the container staying up
docker rm -f chronograf-probe; docker volume rm chronograf-probe-config
forgetool containers test --image chronograf:1.11.7 --config ./apps/chronograf/container-test.yaml
```

Also confirm from outside the container: `curl -i http://<container-ip>:8888/`. Optionally try arm64 only if the amd64 loop is clean.

## 12. PR checklist

- Branch `feat/add-chronograf`, commit and PR title `feat(chronograf): add new container`, target `main`.
- Fill in `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, check only the boxes that apply.
- Put `🤖 This PR is AI generated.` in the Notes section.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; `license/cla` shows the status).
- State honestly what is untested: arm64 build and run, the exact `GET /` status code, behaviour with a real InfluxDB, OAuth variables, and anything not run if Docker is unavailable (then do not tick "Built container locally").
- `docker buildx bake --print` must pass before commit; scoped to `apps/chronograf/` only.
