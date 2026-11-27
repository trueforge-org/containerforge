# meshcentral — implementation plan
> Source: ./draft.md · Target: apps/meshcentral/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Latest stable `1.3.1` (published 2026-10-23). The chart pins `ghcr.io/ylianst/meshcentral:1.3.2` (values.yaml, appVersion 1.3.2), which does not match 1.3.1. Source: https://api.github.com/repos/Ylianst/MeshCentral/releases/latest |
| Draft vs verified | Draft: "Node.js server with npm dependencies", data under `/config`. Confirmed: upstream `docker/Dockerfile` (commit `f436143527458d56da0336ea3047c006703fb4e4`) builds on `node:24.22.1-alpine3.24` (amd64, arm64) and `alpine:3.24` nodejs for arm/v6 and v7, runs `docker/entrypoint.sh`, and keeps data in `/opt/meshcentral/meshcentral-*` (not `/config`). |
| Renovate | Binary from npm: `datasource=npm depName=meshcentral versioning=semver` (same pattern as `apps/mongosh`). |
| License | Apache-2.0 (GitHub API `spdx_id` = `Apache-2.0`; npm metadata `license: Apache-2.0`): https://api.github.com/repos/Ylianst/MeshCentral/license |
| Source URL | https://github.com/Ylianst/MeshCentral |
| Download | npm package `meshcentral@1.3.1`. Tarball `https://registry.npmjs.org/meshcentral/-/meshcentral-1.3.1.tgz`. No GitHub release assets on tag `1.3.1` (empty). Install with npm on both amd64 and arm64; the package is published, so no source build of MeshCentral itself. |
| Checksum source | npm registry metadata for `meshcentral@1.3.1`: `dist.integrity` = `sha512-adf9wyq+78RK6HTRNlF0OO9sPs6dzDaYlScaHRqs2w8xefm/QmS/zdrwuV2UuWWiOqh1RWPxgGNVwF/qvjL0Xg==`, `dist.shasum` = `ce04bd23194cf9fc2f698c25be460629fef405fb` (https://registry.npmjs.org/meshcentral/1.3.1). npm verifies the integrity on install. Package signatures (`dist.signatures`) also present. |
| Upstream Dockerfile reviewed | `docker/Dockerfile`, `docker/entrypoint.sh` (first 90 and the database/feature sections, lines 90+ partly read), `docker/config.json.template` (raw.githubusercontent.com, commit `f4361435...`). |
| Dependencies (runtime, from npm 1.3.1) | `ws`, `express` 4.22.2, `express-ws`, `@seald-io/nedb` 4.1.2, `node-forge`, `otplib`, `@zip.js/zip.js`, `express-handlebars`, `compression`, `cookie-session`, `cbor`, `yauzl`, `multiparty`, `ua-parser-js`, `ipcheck`, `minimist` (https://registry.npmjs.org/meshcentral/1.3.1). `engines.node` = `>=20.0.0`. |
| Port | `PORT=443` (HTTPS) and `REDIR_PORT=80` (HTTP to HTTPS redirect) upstream. Both are privileged (below 1024). See section 9. |
| Env vars (confirmed in upstream Dockerfile or entrypoint) | `NODE_ENV=production`, `CONFIG_FILE=/opt/meshcentral/meshcentral-data/config.json`, `DYNAMIC_CONFIG=false`, `ALLOW_PLUGINS=false`, `ALLOW_NEW_ACCOUNTS=false`, `ALLOWED_ORIGIN=false`, `HOSTNAME=localhost`, `PORT=443`, `REDIR_PORT=80`, `INSTALL_STYLISHUI=false`, `IFRAME=false`, `LOCAL_SESSION_RECORDING=true`, `MINIFY=true`, `REVERSE_PROXY`, `REVERSE_PROXY_TLS_PORT=443`, `REGEN_SESSIONKEY=false`, `STYLISHUI_FORCE_LATEST=false`, `WEBRTC=false`, `TRUSTED_PROXY`, `ARGS`. Database: `USE_MONGODB`, `USE_POSTGRESQL`, `USE_MARIADB` (all `false`), `PSQL_HOST`, `PSQL_PORT=5432`, `PSQL_USER`, `PSQL_PASS`, `PSQL_DATABASE`, `MARIADB_*`, `MONGO_*`. |
| Data path | Upstream volumes: `/opt/meshcentral/meshcentral-data`, `meshcentral-files`, `meshcentral-web`, `meshcentral-backups`. `config.json` at `CONFIG_FILE`. The chart mounts PVCs at these paths; the draft's `/config` is a ContainerForge choice. |
| Process | `ENTRYPOINT ["/bin/bash", "/opt/meshcentral/entrypoint.sh"]`; entrypoint applies env to `config.json` with `jq`/`sed`, traps SIGTERM, then starts MeshCentral. |

## 2. Target layout

- `apps/meshcentral/Dockerfile`
- `apps/meshcentral/docker-bake.hcl`
- `apps/meshcentral/settings.yaml`
- `apps/meshcentral/container-test.yaml`
- `apps/meshcentral/start.sh`
- `apps/meshcentral/defaults/config.json.template` (copied from `docker/config.json.template`, the seed for `/config`; `defaults/` is in `include/.dockerignore`)

No `etc/` or `health/` needed. No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base). The upstream `entrypoint.sh` is not copied: its database and feature handling is replaced by a short `start.sh` (section 7), and any database connector is added later as a separate change.

## 3. Base image

`FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5` for the build and final stages. MeshCentral is a pure Node.js server, so node is the only runtime needed. Alpine (upstream `node:24.22.1-alpine3.24`) is not reusable: the image is musl and ContainerForge is glibc Ubuntu. Node version inside the base is UNVERIFIED; upstream engine `>=20.0.0` is met if the base node is 20 or newer (budge's comment suggests Node 24). Closest siblings: `apps/changedetection` (python-node, build deps, `USER apps`), `apps/mongosh` (npm-packaged tool, `datasource=npm`).

## 4. Dockerfile

Two stages on the same base. `USER root` only for apt steps.

1. `ARG VERSION`, `ARG TARGETARCH`, `# renovate: datasource=npm depName=meshcentral versioning=semver` above `ARG VERSION=1.3.1` (matches `docker-bake.hcl`).
2. Build stage: `apt-get install -y --no-install-recommends build-essential python3` only if a native module needs compiling. Upstream `dep-compiler` installs `gcc g++ make python3` for native modules; the npm 1.3.1 runtime list above shows no obvious native module, so check with `npm install` output first (UNVERIFIED for transitive natives). Keep the build stage out of the final image.
3. Build stage env: `ENV npm_config_cache=/tmp/npm npm_config_update_notifier=false`.
4. `mkdir -p /app/meshcentral && cd /app/meshcentral` inside the build stage (not the final image). `npm install --omit=dev --no-audit --no-fund meshcentral@${VERSION}`. npm verifies `dist.integrity`. Then `npm cache clean --force` and `rm -rf /tmp/npm`.
5. Final stage: `USER root`, `apt-get install -y --no-install-recommends curl` only if the base lacks it (check first; upstream runs `curl` for healthchecks, not needed here since `container-test.yaml` probes ports). Clean `/var/lib/apt/lists/*`.
6. `COPY --from=build --chmod=0755 /app/meshcentral /app/meshcentral` (copies `node_modules` and the package).
7. Symlinks so MeshCentral's default data directories resolve into `/config` (the upstream directories stay absolute in MeshCentral's own layout):
   - `RUN ln -s /config/meshcentral-data /app/meshcentral/meshcentral-data && ln -s /config/meshcentral-files /app/meshcentral/meshcentral-files && ln -s /config/meshcentral-web /app/meshcentral/meshcentral-web && ln -s /config/meshcentral-backups /app/meshcentral/meshcentral-backups`
   Dangling until `start.sh` creates the targets. Decision: symlinks, not `--datapath`, because `--datapath` is UNVERIFIED for 1.3.1.
8. License: `COPY --from=build /app/meshcentral/node_modules/meshcentral/LICENSE /usr/share/licenses/meshcentral/LICENSE` (UNVERIFIED that the package ships a LICENSE file; if not, copy the Apache-2.0 text from the upstream repo at tag `1.3.1`).
9. Tail:

```dockerfile
ENV NODE_ENV=production \
    CONFIG_FILE=/config/meshcentral-data/config.json \
    DYNAMIC_CONFIG=false \
    PORT=8443 \
    REDIR_PORT=8080 \
    HOSTNAME=localhost
USER apps
COPY --chmod=0755 . /
EXPOSE 8443 8080
VOLUME /config
WORKDIR /app/meshcentral
```

No `ENTRYPOINT` override: the `ubuntu` base entrypoint (`tini` then `/entrypoint.sh`) execs `/start.sh`.

`PORT=8443` and `REDIR_PORT=8080` are deliberate, see section 9. `CONFIG_FILE` points at `/config`, not `/opt/meshcentral`.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "meshcentral"
}

variable "VERSION" {
  // renovate: datasource=npm depName=meshcentral versioning=semver
  default = "1.3.1"
}

variable "LICENSE" {
  default = "Apache-2.0"
}

variable "SOURCE" {
  default = "https://github.com/Ylianst/MeshCentral"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
  }
  labels = {
    "org.opencontainers.image.source" = "${SOURCE}"
    "org.opencontainers.image.licenses" = "${LICENSE}"
  }
}

target "image-local" {
  inherits = ["image"]
  output = ["type=docker"]
  tags = ["${APP}:${VERSION}"]
}

target "image-all" {
  inherits = ["image"]
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}
```

Validate with `docker buildx bake --print` from `apps/meshcentral/`. The `VERSION` default and the Dockerfile `ARG VERSION` must both be `1.3.1`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/Ylianst/MeshCentral"
ports:
  - port: 8443
    protocol: tcp
    required: true
  - port: 8080
    protocol: tcp
    required: false
env:
  - name: HOSTNAME
    default: "localhost"
    required: true
  - name: PORT
    default: "8443"
    required: false
  - name: REDIR_PORT
    default: "8080"
    required: false
  - name: ALLOW_NEW_ACCOUNTS
    default: "false"
    required: false
  - name: ALLOW_PLUGINS
    default: "false"
    required: false
  - name: IFRAME
    default: "false"
    required: false
  - name: WEBRTC
    default: "false"
    required: false
  - name: REVERSE_PROXY
    default: ""
    required: false
  - name: REVERSE_PROXY_TLS_PORT
    default: "443"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
opt_dependencies:
  - postgresql
```

Only variables `start.sh` reads are listed. Database connector variables (`USE_POSTGRESQL`, `PSQL_*`, and so on) are NOT listed: the connector is out of scope for this first version (section 7). `HOSTNAME` is required and has a default, so `start.sh` must still run without it (default `localhost`, which agents cannot use; say so in the description). `TZ` only if the base honours it. `opt_dependencies` only if a database connector is later wired in; keep it for the PR text, remove it if the reviewer prefers.

## 7. start.sh

```bash
#!/bin/bash
set -eu

DATA=/config/meshcentral-data
PORT="${PORT:-8443}"
REDIR_PORT="${REDIR_PORT:-8080}"
HOSTNAME="${HOSTNAME:-localhost}"

mkdir -p "$DATA" /config/meshcentral-files /config/meshcentral-web /config/meshcentral-backups

# Seed config.json only when missing or empty. Never overwrite user state.
if [ ! -s "$DATA/config.json" ]; then
  cp /defaults/config.json.template "$DATA/config.json"
fi

# Apply the port and hostname from env on every start (the values the user sets must win).
jq --argjson port "$PORT" --argjson redir "$REDIR_PORT" --arg host "$HOSTNAME" \
  '.settings.port = $port | .settings.redirPort = $redir | .domains[""].dns = $host' \
  "$DATA/config.json" > "$DATA/config.json.tmp" && mv "$DATA/config.json.tmp" "$DATA/config.json"

cd /app/meshcentral
exec node node_modules/meshcentral/meshcentral.js
```

- UNVERIFIED: `jq` is present in the base image (check with `command -v jq`; add the apt package only if missing).
- Idempotent: empty `/config` is seeded from `defaults/config.json.template`; a populated `/config` keeps its `config.json` and only the three env-driven keys are rewritten each start.
- Never writes to `/app`: the symlinks from the Dockerfile point into `/config`.
- The `jq` expression above is the only env mapping in this version: `.domains[""].dns` is the hostname agents use. Whether MeshCentral reads `domains[""].dns` or `settings.cert` for the enrollment host name is UNVERIFIED: check the template's keys and the upstream `entrypoint.sh` lines 90+ (not fully read) before the first build. Adjust the jq path to the real key.
- Password and session secrets: no secrets from env are written to files in this version. `REGEN_SESSIONKEY` is not wired (out of scope).
- Caches: npm and node temp to `/tmp` (`TMPDIR=/tmp`, verify in section 11).
- `exec node node_modules/meshcentral/meshcentral.js` (the npm layout; the data folders sit beside `node_modules`, hence the symlinks) makes node PID 1 for signal handoff. Upstream's SIGTERM trap (`kill -SIGINT`) is not needed for a single node process; node handles SIGINT/SIGTERM, verify on stop.
- Bind all interfaces: MeshCentral listens on all interfaces by default; confirm the log shows the configured port on `0.0.0.0`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 300
tcp:
- port: '8443'
- port: '8080'
filePaths:
- /app/meshcentral/node_modules/meshcentral/meshcentral.js
- /app/meshcentral/node_modules/meshcentral/package.json
- /config/meshcentral-data/config.json
- /usr/share/licenses/meshcentral/LICENSE
- /start.sh
```

- Both ports from `settings.yaml` have a `tcp` probe. No `http` probe: `8443` is HTTPS with a self-signed certificate created on the first start, and the forgetool http check is not known to accept it (UNVERIFIED); `tcp` is the honest check.
- `timeoutSeconds: 300`: first start generates the certificate and the data directory. Tune after the first run; never lower it to hide a slow start.
- `/config/meshcentral-data/config.json` is checked after start, so the seed must happen on an empty `/config`. Confirm the test volume starts empty (forgetool default).
- Tests run without env vars, so the default `HOSTNAME=localhost` and the default ports are what gets tested. No env-dependent code path is exercised; say so in the PR.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | ContainerForge remap |
| --- | --- |
| `/opt/meshcentral/meshcentral-data` (config.json, certificates, NeDB database files, session key) | `/config/meshcentral-data` (symlink from `/app/meshcentral/meshcentral-data`) |
| `/opt/meshcentral/meshcentral-files` (uploaded files) | `/config/meshcentral-files` |
| `/opt/meshcentral/meshcentral-web` (custom web content) | `/config/meshcentral-web` |
| `/opt/meshcentral/meshcentral-backups` | `/config/meshcentral-backups` |
| `CONFIG_FILE=/opt/meshcentral/meshcentral-data/config.json` | `CONFIG_FILE=/config/meshcentral-data/config.json` |
| Ports 443 and 80 (privileged) | 8443 and 8080 inside the container (non-root cannot bind below 1024). The chart's Service maps 443/80 to these ports, so the chart keeps its external ports. Users who want 443 on the host can map it with the runtime, or set `net.ipv4.ip_unprivileged_port_start`; do not change the default. |
| Upstream `root` user (no USER in the fetched Dockerfile) | `USER apps` |

The `config.json` secret mount from the chart (`/opt/meshcentral/meshcentral-data/config.json`, read-only) is replaced by the seeded `/config` file; users who mount a read-only secret must mount it at `/config/meshcentral-data/config.json` (note in the PR).

Read-only rootfs check: run with `--read-only --tmpfs /tmp`. Node and npm writes go to `/config` or `/tmp`.

## 10. Risks, caveats and open questions

- Ports: 8443 and 8080 are a deliberate ContainerForge change from 443 and 80. Enrollment URLs for agents include the port, so the user-facing URL changes unless the reverse proxy or chart Service maps it. This is the main product decision: confirm before merging.
- Hostname: agents enroll against the server host name. The default `HOSTNAME=localhost` is not usable for real devices. The draft caveat is right; `start.sh` must write the real name, and the exact `config.json` key is UNVERIFIED (section 7).
- Node version in the python-node base is UNVERIFIED. MeshCentral requires node `>=20.0.0`.
- `defaults/config.json.template` comes from upstream `docker/config.json.template` (commit `f4361435...`). It contains a `$schema` URL and placeholder values (`myserver.mydomain.com`, `MyReallySecretPassword1`); the `_sessionKey` value is a placeholder: remove it from the seeded file or regenerate it on first start, and say so in the PR (do not ship a known secret).
- Upstream `dep-compiler` adds `modern-syslog`, `telegram`, `ssh2`, `nodemailer`, `image-size`, `wildleek`, `yub`, `mongodb`, `pg` and `mariadb` only when enabled through build args. None are added here; the default upstream build does not enable them, so no native build is needed in the plan. Transitive natives are UNVERIFIED.
- Upstream `entrypoint.sh` also handles MongoDB, PostgreSQL, MariaDB, Stylish UI, plugins and WebRTC via env: out of scope for this first version. Document it; add connectors as a follow-up.
- Dangling symlinks: `start.sh` must create the `/config` targets before `node` starts, or MeshCentral writes fail. Covered by the `mkdir -p` in section 7.
- Draft caveat "first start generates certificates and a data directory": confirmed as expected behavior, not verified on a fetched page: verify on first start.
- Blockers: none confirmed. Main risks: port change (product decision), hostname key, Node version.

## 11. Build and test steps

Run from `/workspaces/containers/apps/meshcentral/` (copy the files there; the draft folder stays unchanged):

1. `docker buildx bake --print` (must exit 0).
2. Check base facts: `docker run --rm ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409... sh -c 'node -v; echo $TMPDIR'`.
3. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
4. Check the seeded config keys before the probe: `docker run --rm --entrypoint sh meshcentral:1.3.1 -c 'cat /defaults/config.json.template | head -40'` (confirms the jq key for the hostname from section 7).
5. Probe: `docker run --rm -d --name meshcentral-probe --read-only --tmpfs /tmp -v meshcentral-probe-config:/config meshcentral:1.3.1`, then `docker logs -f meshcentral-probe`.
6. Readiness signal: a log line showing the server listening on the configured port (for example `Server listening on port 8443` or the equivalent MeshCentral startup line), process still running, no fatal errors or repeated stack traces after the first minute. `config.json` exists under `/config/meshcentral-data`.
7. `forgetool containers test --image meshcentral:1.3.1 --config ./container-test.yaml`.
8. Cleanup: `docker rm -f meshcentral-probe; docker volume rm meshcentral-probe-config`.
9. Repeat step 5 with the same volume (restart check): config.json must keep its user values, and the container must start again.
10. Arm64 only after amd64 is green: `--set image-local.platform=linux/arm64`.

## 12. PR checklist

- Branch: `feat/add-meshcentral`. Commit: `feat(meshcentral): add new container`. PR title matches the commit.
- Notes: `🤖 This PR is AI generated.`
- Fill in `.github/PULL_REQUEST_TEMPLATE.md`, keeping sections and checkboxes; check only what applies. Do not check "Built container locally" unless steps 3 to 5 passed.
- Say what was not tested: arm64 build, the database connectors, plugins, WebRTC, reverse-proxy setups, agent enrollment from another host, the exact hostname key (if not verified), the port change impact on chart Services.
- Explain the 8443/8080 port change and the `/config` path change in the PR body.
- CLA: the user must sign at https://cla-assistant.io/trueforge-org/containerforge (`license/cla` check). Only the user can sign it.
- `VERSION` renovate annotation present; `docker buildx bake --print` passed.
- Container-test: tcp probes for 8443 and 8080.
