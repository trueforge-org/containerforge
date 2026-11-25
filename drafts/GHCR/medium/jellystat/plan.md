# jellystat — implementation plan
> Source: ./draft.md · Target: apps/jellystat/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `1.1.12`. Release tag published 2026-09-08 (https://github.com/CyferShepard/Jellystat/releases/tag/1.1.12). It is also the latest release (`gh api repos/CyferShepard/Jellystat/releases/latest`). `package.json` version is `1.1.12` (https://raw.githubusercontent.com/CyferShepard/Jellystat/e0a38eeeff4c4bbaba60abad5f76e8a54415d1a8/package.json). The draft's `:latest` pin is not reproducible and must be replaced by `1.1.12`. |
| Renovate | `datasource=github-releases depName=CyferShepard/Jellystat versioning=semver` (UNVERIFIED against repo renovate config) |
| License | MIT (GitHub API, `repos/CyferShepard/Jellystat` spdx_id `MIT`) |
| Source URL | https://github.com/CyferShepard/Jellystat |
| Binary | No release assets. The artifact is the source at the tag, built with npm (Vite client, Node server). It is arch-neutral JS. |
| Checksum source | None published. Pin the tag, and record the sha256 of the tarball `https://github.com/CyferShepard/Jellystat/archive/refs/tags/1.1.12.tar.gz` in `ARG JELLYSTAT_SHA256`. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/CyferShepard/Jellystat/e0a38eeeff4c4bbaba60abad5f76e8a54415d1a8/Dockerfile. Builder `node:26-bookworm-slim`: `npm install`, `npm run build`. Runtime `node:26-bookworm-slim`: `apt-get install wget`, `COPY --from=builder /app .`, `COPY --chmod=755 entry.sh /entry.sh`, `EXPOSE 3000`, `HEALTHCHECK` on `/auth/isconfigured`, `CMD ["/entry.sh"]`. No `USER` (runs as root), no `ENV`, no `VOLUME`. |
| Entrypoint reviewed | `entry.sh` (https://raw.githubusercontent.com/CyferShepard/Jellystat/e0a38eeeff4c4bbaba60abad5f76e8a54415d1a8/entry.sh): loads every `FILE__<NAME>` variable into `<NAME>` (Docker secrets pattern), then `npm run start`, which is `cd backend && node server.js`. |
| Ports | 3000/tcp (`EXPOSE 3000`, and `ports: 3000:3000` in upstream compose) |
| Env vars the app reads (upstream compose) | `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_IP`, `POSTGRES_PORT` (5432), `JWT_SECRET`, `TZ`, plus the `FILE__<NAME>` secret loader. Source: https://raw.githubusercontent.com/CyferShepard/Jellystat/e0a38eeeff4c4bbaba60abad5f76e8a54415d1a8/docker-compose.yml (fetched via `gh api`). Whether `JWT_SECRET` is hard-required is UNVERIFIED. |
| Data write paths | `/app/backend/backup-data` (backup volume in upstream compose; the draft's chart persists it too). |
| Database | External PostgreSQL. Upstream compose uses `postgres:18.1`; the ContainerForge `postgresql` app is the dependency. |
| arm64 | UNVERIFIED: the upstream ghcr manifest was not checked. The app is arch-neutral JS, and node is multi-arch. |
| Dependencies | postgresql (hard, apps/postgresql exists) |
| Blockers | None. Secrets come from env, which ContainerForge already supports through `FILE__` and `settings.yaml`. |

## 2. Target layout

- `apps/jellystat/Dockerfile`
- `apps/jellystat/docker-bake.hcl`
- `apps/jellystat/settings.yaml`
- `apps/jellystat/container-test.yaml`
- `apps/jellystat/start.sh` (replaces upstream `entry.sh`, which is not copied; reason: its `FILE__` loader is reproduced in `start.sh`)

No `defaults/`, `etc/`, `health/` needed. No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

Runtime: `FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5`. The draft chose this base. The copilot instructions map "Node" to `ghcr.io/trueforge-org/ubuntu`. A pure Node app would therefore normally use ubuntu. The python-node base already carries Node, and the deviation is recorded in section 10 as a decision for the user.

Build stage: the same `python-node` base (node and npm are already there), so `npm ci` and `npm run build` run with the pinned base.

Closest sibling: `apps/changedetection` and `apps/budge` (python-node with a node build). Check whether either has a pure Node sibling pattern before finalising (UNVERIFIED).

## 4. Dockerfile

1. Build stage: `FROM <python-node> AS build`, `ARG VERSION`, `ARG JELLYSTAT_SHA256`, `USER root`, `WORKDIR /tmp/src`.
2. `curl -fL -o /tmp/jellystat.tar.gz https://github.com/CyferShepard/Jellystat/archive/refs/tags/${VERSION}.tar.gz`, `echo "${JELLYSTAT_SHA256}  /tmp/jellystat.tar.gz" | sha256sum -c -`, `tar xzf ... --strip-components=1 -C /tmp/src`.
3. `ENV NPM_CONFIG_CACHE=/tmp/npm-cache` (rule: caches go to `/tmp`). `npm ci` (lockfile present in the tarball; UNVERIFIED the tarball has `package-lock.json`, upstream uses `npm install`, so use `npm install` if no lockfile), then `npm run build`.
4. Final stage: `FROM <python-node>`, `USER root`, `apt-get install -y --no-install-recommends wget` only if the healthcheck tool is needed (the probe is in `container-test.yaml` instead, so skip it), `clean apt lists`.
5. `COPY --from=build /tmp/src /app`. Make the backend write path a symlink: `mkdir -p /app/backend && ln -s /config/backup-data /app/backend/backup-data`.
6. `chown -R apps:apps /app` is not needed. `/app` stays read-only at runtime; the build puts files owned by root.
7. `ENV TZ=Etc/UTC`.
8. Tail:

```dockerfile
EXPOSE 3000
VOLUME /config
USER apps
COPY --chmod=0755 . /
```

Set `CMD ["/start.sh"]` only if `start.sh` is the entry; the base `CMD` pattern is in `apps/python-node` (check before setting).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "jellystat"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=CyferShepard/Jellystat versioning=semver
  default = "1.1.12"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/CyferShepard/Jellystat"
}
```

Then the four standard targets and the `default` group copied from `apps/bookstack/docker-bake.hcl`. `ARG VERSION` in the Dockerfile must equal this default. Run `docker buildx bake --print` from `apps/jellystat/`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/CyferShepard/Jellystat"
ports:
  - port: 3000
    protocol: tcp
    required: false
env:
  - name: POSTGRES_USER
    default: "postgres"
    required: false
  - name: POSTGRES_PASSWORD
    default: ""
    required: true
  - name: POSTGRES_IP
    default: "postgresql"
    required: true
  - name: POSTGRES_PORT
    default: "5432"
    required: false
  - name: JWT_SECRET
    default: ""
    required: true
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies:
  - postgresql
```

Notes: `required: true` env vars need a default or start.sh generation (rule). `POSTGRES_PASSWORD` is handled by `start.sh` on each start (rule for DBs), and `JWT_SECRET` is generated in `start.sh` into `/config` when empty (see section 7). The `POSTGRES_IP` default `postgresql` is the ContainerForge dependency name (UNVERIFIED that the app name resolves that way, so check in the chart). Do not list env vars the app does not read.

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config/backup-data /tmp/npm-cache

# FILE__<NAME> secret loader, as upstream entry.sh
for var in $(env | grep '^FILE__'); do
  name="${var%%=*}"
  path="${var#*=}"
  if [ -f "${path}" ]; then
    export "${name#FILE__}=$(cat "${path}")"
  else
    echo "Error: Secret file '${path}' does not exist"
    exit 1
  fi
done

# JWT secret: generate once and keep it in /config
if [[ -z "${JWT_SECRET}" ]]; then
  if [[ ! -s /config/jwt_secret ]]; then
    head -c 32 /dev/urandom | base64 > /config/jwt_secret
  fi
  export JWT_SECRET="$(cat /config/jwt_secret)"
fi

# apply DB password from env on every start
export POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-}"

cd /app
exec npm run start
```

Notes: idempotent, seeds `/config` only when missing, never writes to `/app`. `exec` hands PID 1 to node. The `FILE__` loader is reproduced from upstream `entry.sh`; the upstream file is not copied. Keep secrets out of the process list: `npm run start` reads them from the environment, which is acceptable here because that is how the app reads them (UNVERIFIED whether the Node process exposes them via `/proc`, which is the same as upstream).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '3000'
http:
- port: '3000'
  path: /auth/isConfigured
filePaths:
- /app/backend/server.js
- /app/backend/backup-data
```

`/auth/isConfigured` is the upstream healthcheck path (from the Dockerfile's HEALTHCHECK). It does not need the DB to return a response (UNVERIFIED: the app may return a 5xx without a DB). If it fails for that reason, this is a DB-dependency narrowing: keep the `tcp` probe on 3000 and add the comment `# narrowed: requires external postgresql; full functional test not feasible in single-container suite`. The narrowing applies only because all three criteria in the protocol hold (hard dependency, cannot start without DB, not feasible with the primitives).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/app/backend/backup-data` | Symlink `/app/backend/backup-data` -> `/config/backup-data`, created in the Dockerfile |
| npm cache during build | `NPM_CONFIG_CACHE=/tmp/npm-cache` (build stage only) |
| JWT secret when unset | `/config/jwt_secret`, generated once by `start.sh` |
| Node `tmp` and runtime scratch | `/tmp` (set by the `--tmpfs /tmp` run flag) |

The draft expected `runAsUser 0`, `readOnlyRootFilesystem false`, `privileged false`. This plan runs as `apps` (non-root). It is `--read-only` compatible only if no other runtime write exists (verify in the run; UNVERIFIED for the Jellystat logger).

## 10. Risks, caveats and open questions

- Base choice: the draft uses `python-node`, while the copilot table maps pure Node to ubuntu. Decision for the user. The plan keeps `python-node` (already has node, matches the draft), and the deviation must be stated in the PR.
- Version pin: the draft's `latest` is replaced by `1.1.12`, which is verified to exist. Renovate tracks it going forward.
- Lockfile: the upstream Dockerfile uses `npm install` (not `npm ci`), so whether a lockfile exists in the tarball is UNVERIFIED.
- Postgres image: upstream compose uses `postgres:18.1`; ContainerForge's `postgresql` app version may differ. Check the app's `VERSION` before the PR.
- `JWT_SECRET`: the generated fallback in `start.sh` is ContainerForge's choice, not upstream's. It must be stated in the PR.
- Upstream chart uses the untagged `latest` image (draft caveat). This plan builds a pinned version, so that caveat is resolved by the plan.
- Blockers: none. arm64 UNVERIFIED.

## 11. Build and test steps

```sh
cd apps/jellystat
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name jellystat-probe --read-only --tmpfs /tmp \
  -e POSTGRES_IP=127.0.0.1 -e POSTGRES_PASSWORD=unused \
  -v jellystat-probe-config:/config jellystat:1.1.12
docker logs -f jellystat-probe
forgetool containers test --image jellystat:1.1.12 --config ./apps/jellystat/container-test.yaml
docker rm -f jellystat-probe; docker volume rm jellystat-probe-config
```

Expected readiness signal: the Node server logs its listen line for port 3000 (UNVERIFIED exact text; check the first run), the process stays alive, and `/config/jwt_secret` exists after the first start with an empty `JWT_SECRET`. Test the DB path by running `docker compose`-style with a real `postgresql` container (out of scope for the single-container suite).

## 12. PR checklist

- Branch `feat/add-jellystat`, commit and PR title `feat(jellystat): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, check only what applies.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows status.
- Untested to state honestly: the DB-connected functional path, the `python-node` vs ubuntu base choice, arm64, and the read-only run.
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION`; no assertion weakened.
