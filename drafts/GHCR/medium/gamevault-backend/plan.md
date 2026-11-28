# gamevault-backend — implementation plan
> Source: ./draft.md · Target: apps/gamevault-backend/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | 17.2.0, published 2026-11-04T21:52:42Z, not a prerelease (`gh api repos/Phalcode/gamevault-backend/releases/latest`; https://github.com/Phalcode/gamevault-backend/releases/tag/17.2.0). |
| Renovate | `datasource=github-releases depName=Phalcode/gamevault-backend versioning=semver` |
| License | Repo license reported as NOASSERTION. The `LICENSE` file at tag 17.2.0 is Creative Commons Attribution-NonCommercial-ShareAlike 4.0 (`CC-BY-NC-SA-4.0`); non-commercial terms, flag to the maintainers before publishing. |
| Source URL | https://github.com/Phalcode/gamevault-backend |
| Binary | None: the release has no assets. Build from source at tag `17.2.0`: `https://github.com/Phalcode/gamevault-backend/archive/refs/tags/17.2.0.tar.gz`. |
| Checksum | None published. Pin the tag and verify the tarball. |
| Upstream Dockerfile | https://raw.githubusercontent.com/Phalcode/gamevault-backend/17.2.0/Dockerfile: stages `base` (`node:lts-slim`, `npm i -g pnpm@11`, PostgreSQL client, `WORKDIR /app`), `build` (`pnpm install --frozen-lockfile`, `pnpm run build`), `prod-deps` (`pnpm install --prod --frozen-lockfile`), `release` (copies `dist` and `node_modules`, `NODE_ENV=production`, `ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]`, `CMD ["dist/src/main.js"]`, `HEALTHCHECK curl http://localhost:${SERVER_PORT}/api/status`). No USER, no VOLUME. |
| Ports | `SERVER_PORT=8080` (http), `SERVER_HTTPS_PORT=8443` (https) (upstream ENV and EXPOSE). |
| Upstream env | `TZ=Etc/UTC`, `PUID=1000`, `PGID=1000`, `PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true`, `NPM_CONFIG_PREFIX=/home/node/.npm-global`, `PNPM_HOME=/pnpm`, `YES=yes`. |
| Upstream data dirs | `/config /files /media /logs /db /plugins /savefiles`, created and `chmod -R 777` in release. Which one holds uploads: UNVERIFIED (Dockerfile names no upload dir). |
| Upstream entrypoint | `/usr/local/bin/entrypoint.sh`: not fetched. How it applies PUID/PGID: UNVERIFIED. |
| Database | PostgreSQL required (draft and chart). Env names for the DB connection: UNVERIFIED (app source and docs not read). |
| Node | Base is `node:lts-slim`. Node version required by pnpm 11: UNVERIFIED. |
| Dependencies | `postgresql` (hard). `apps/postgresql` exists, so the mark is ✅. |

## 2. Target layout

- `apps/gamevault-backend/Dockerfile`
- `apps/gamevault-backend/docker-bake.hcl`
- `apps/gamevault-backend/settings.yaml`
- `apps/gamevault-backend/container-test.yaml`
- `apps/gamevault-backend/start.sh` (replaces upstream `entrypoint.sh`)

No `defaults/`, `etc/`, `health/`, `root/`. No `DOWNSTREAM_CHANGES.md` (not a FROM base).

## 3. Base image

`FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5`, as the draft specifies. Closest sibling: `apps/budge` (node build on the same base). The node major version of the base is UNVERIFIED against pnpm 11's requirement. If it is too old, switch the base to `ghcr.io/trueforge-org/ubuntu` and install node (decision after the first build).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Build stage `FROM <python-node> AS build`:
   - `curl -fL https://github.com/Phalcode/gamevault-backend/archive/refs/tags/${VERSION}.tar.gz | tar xz -C /tmp/src --strip-components=1` (no published checksum; record the tarball SHA-256 in the PR).
   - `ENV PNPM_HOME=/tmp/pnpm NPM_CONFIG_PREFIX=/tmp/npm-global PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true`. Use `npm i -g pnpm@<pinned to the upstream Dockerfile, 11>`.
   - `cd /tmp/src && pnpm install --frozen-lockfile && pnpm run build`.
   - `pnpm install --prod --frozen-lockfile` into a clean `prod` directory (or prune) so prod deps are separate from dev.
3. Final stage `FROM <python-node>`:
   - PostgreSQL client: check the base first; install `postgresql-client` only if the app needs `psql`/`pg_dump` and the base lacks it (pin version if from apt).
   - `mkdir -p /app/gamevault-backend && COPY --from=build /tmp/src/dist /app/gamevault-backend/dist` and the prod `node_modules`, `package.json`.
   - License: `COPY --from=build /tmp/src/LICENSE /usr/share/licenses/gamevault-backend/LICENSE` .
4. `ENV NODE_ENV=production SERVER_PORT=8080 HOME=/tmp TZ=Etc/UTC`. Do not carry PUID/PGID: the image runs as `apps`.
5. `EXPOSE 8080`, `VOLUME /config`, `WORKDIR /app/gamevault-backend`.
6. Final: `USER apps`, `COPY --chmod=0755 . /`.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "gamevault-backend" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=Phalcode/gamevault-backend versioning=semver
  default = "17.2.0"
}
variable "LICENSE" { default = "UNVERIFIED" }   // blocked until the LICENSE file is read
variable "SOURCE" { default = "https://github.com/Phalcode/gamevault-backend" }
```

Four standard targets and the default group copied from `apps/budge/docker-bake.hcl`. `image-all`: `linux/amd64`, `linux/arm64` (both are built from source, so both should work; verify). Run `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/Phalcode/gamevault-backend"
ports:
  - port: 8080
    protocol: tcp
    required: true
dependencies:
  - name: postgresql
env:
  - name: SERVER_PORT
    default: "8080"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
  # DB connection env names: UNVERIFIED, add from app source before finalising
volumes:
  - path: /config
    required: true
```

Do not list 8443 unless HTTPS is implemented in the start script. Dependency `postgresql` is marked ✅ (`apps/postgresql` exists). Add each DB env var the app reads only after confirming its name from source.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail
export VOLUMES_FILES="${VOLUMES_FILES:-/config/files}"   # also VOLUMES_IMAGES=/config/media, VOLUMES_LOG=/config/logs (names from the chart)
mkdir -p "${VOLUMES_FILES}" /config/media /config/logs
export SERVER_PORT="${SERVER_PORT:-8080}"
# upload/log/data paths: confirm the env names from source and point them at /config
cd /app/gamevault-backend
exec node dist/src/main.js
```

Rules: idempotent; seed nothing unless a default config is required; DB password applied from env on every start (the protocol rule); no write to `/app`; caches to `/tmp`; `exec` the process. Wait for PostgreSQL: the backend exits without it, so the start script should retry the DB connection a bounded number of times rather than loop forever (decision after reading source).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 300
tcp:
- port: '8080'
filePaths:
- /app/gamevault-backend/dist/src/main.js
- /usr/share/licenses/gamevault-backend/LICENSE
```

The DB dependency exception applies: it has a hard `postgresql` dependency (criterion 1), the process will not serve without the DB (criterion 2), and a sidecar DB is not wired in `container-test.yaml` with these primitives (criterion 3, to confirm). If all three hold, narrow the assertions and add the required comment:

```yaml
# narrowed: requires external postgresql; full functional test not feasible in single-container suite
```

Under the narrowed mode, the run must still show the process staying up and the startup log line, per the build protocol. Never disable the tcp probe. Probe with a healthcheck path only if the server answers it without a DB (UNVERIFIED).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/config`, `/files`, `/media`, `/logs`, `/db`, `/plugins`, `/savefiles` (chart PVCs `/logs`, `/media`, `/games`) | `/config/<name>` for each one the app actually writes; everything else read-only |
| Uploads (location UNVERIFIED) | `/config/upload` |
| `chmod -R 777` on data dirs | Not needed: `apps` owns `/config` |
| PUID/PGID handling in upstream entrypoint | Removed; image runs as `apps` |
| npm/pnpm home and caches | `/tmp` |

Draft reconciled: draft says chart runs as UID 0 and `runAsNonRoot: false`. This image runs as `apps`. Chart `readOnlyRootFilesystem: false`: the target is compatible with `--read-only --tmpfs /tmp` once uploads move to `/config`.

## 10. Risks, caveats and open questions

- Needs human decision, license: the LICENSE file is CC-BY-NC-SA-4.0 (non-commercial), which may not allow redistribution as an image. Confirm before publishing.
- BLOCKER, DB env names and upload path: not read from source. Read the config reference before writing `start.sh` and `settings.yaml`.
- BLOCKER, node version: pnpm 11 vs `node:lts-slim`/`python-node` base. Check on the first build.
- The chart's `/logs`, `/media` and `/games` mounts are named but not confirmed as used by the backend. Confirm which the backend writes.
- A separate GameVault client is needed to browse the library. This image does not provide it (inferred).
- The pnpm TypeScript build runs at image build time, so the first build is slow.
- `chmod 777` on upstream data dirs is dropped; confirm the server does not rely on world-writable files.

## 11. Build and test steps

```sh
cd apps/gamevault-backend
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name gamevault-backend-probe --read-only --tmpfs /tmp \
  -v gamevault-backend-probe-config:/config gamevault-backend:17.2.0
docker logs -f gamevault-backend-probe
forgetool containers test --image gamevault-backend:17.2.0 --config ./apps/gamevault-backend/container-test.yaml
docker rm -f gamevault-backend-probe; docker volume rm gamevault-backend-probe-config
```

Expected: with no PostgreSQL, the process should either wait-and-retry (narrowed mode, process stays up) or exit with a clear DB error. Readiness signal: UNVERIFIED (the server's startup line, from source). Test with a PostgreSQL sidecar on a user network to confirm `/api/status` returns 200.

## 12. PR checklist

- Branch `feat/add-gamevault-backend`, commit and PR title `feat(gamevault-backend): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep the sections, check only what applies.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it. The `license/cla` check shows status.
- Not tested, state in the PR: build (if not done), arm64 build, the DB-connected run, the narrowed test rationale, the license.
