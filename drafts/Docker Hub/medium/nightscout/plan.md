# nightscout — implementation plan
> Source: ./draft.md · Target: apps/nightscout/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `15.0.9` (tag `v15.0.9`), GitHub release published 2026-10-21, no release assets. The Hub image in the chart (`docker.io/nightscout/cgm-remote-monitor-travis:latest@sha256:3ace8747...fb271`) is not a release. |
| Difference from draft | Draft's `Hard dependency: no` conflicts with the chart's `MONGO_CONNECTION` (required secret). Treat MongoDB as required. Draft's "Node 22 app with npm and webpack" is confirmed. |
| Hub image | `nightscout/cgm-remote-monitor-travis`: a Travis CI test image, last pushed 2020 (`latest` 2020-12-27, `14.1.0` 2021-01-01), amd64 only. Do not copy from it. Build from the v15.0.9 source. |
| Renovate | `// renovate: datasource=github-releases depName=nightscout/cgm-remote-monitor versioning=semver`. UNVERIFIED against this repo's renovate config. |
| License | AGPL-3.0 (GitHub API `license.spdx_id`; `package.json` `license`). |
| Source URL | https://github.com/nightscout/cgm-remote-monitor. Docs: https://nightscout.github.io/ |
| Download | Source tarball `https://github.com/nightscout/cgm-remote-monitor/archive/refs/tags/v15.0.9.tar.gz`. No release assets. The tarball URL is the standard GitHub tag archive (not fetched). |
| Checksum source | None published. Record the SHA-256 of the tarball in the PR. |
| Upstream Dockerfile reviewed | `Dockerfile` on `master` (two stages on `node:22-alpine`). Builder: `WORKDIR /opt/app`, copies `package.json`, `package-lock.json`, `.babelrc`, `bundle/`, `webpack/`, `bin/generateRandomString.js`, `lib/`, `static/`, `views/`, `translations/`, `server.js`; `npm ci --cache /tmp/empty-cache --omit=optional --force`; `npm prune --omit=dev --omit=optional`. Runtime: `NODE_ENV=production`, `USER node`, `EXPOSE 1337`, `CMD ["node","lib/server/server.js"]`. Note: this `master` Dockerfile is the reference; v15.0.9's Dockerfile is UNVERIFIED. |
| Node version | `package.json` `engines`: `node >=20.x`, `npm >=10.x`. Upstream image uses Node 22. |
| Build | `postinstall`: `webpack --mode production --config webpack/webpack.config.js && npm run-script post-generate-keys`. Start: `node lib/server/server.js`. |
| Ports | `1337` (EXPOSE, chart service `main`). |
| Data and config paths | Chart `persistence: {}`. Upstream writes nothing outside `/opt/app`. `post-generate-keys` writes generated keys into the source tree; the exact path is UNVERIFIED. |
| Env vars (chart, pass-through) | `API_SECRET` (secret, required), `MONGO_CONNECTION` (secret, example `mongodb://db-user:db-password@mongodb-instance:port/db-name`), `BASE_URL`, `BG_HIGH`, `BG_LOW`, `BG_TARGET_BOTTOM`, `BG_TARGET_TOP`, `DISPLAY_UNITS`, `ENABLE` (delta direction upbat timeago devicestatus errorcodes ar2 simplealarms profile), `INSECURE_USE_http` (chart value `"true"`), `THEME` (`colors`), `TIME_FORMAT` (`24`). All from TrueCharts values. UNVERIFIED that v15.0.9 reads each one; the name `INSECURE_USE_http` in the chart may not match the upstream spelling. |
| User | Upstream `USER node` (UID 1000 on node images). Chart forces UID/GID 0. |
| arm64 | Upstream Dockerfile is on a multi-arch base (`node:22-alpine`), so arm64 should build from source. UNVERIFIED for this app; the Hub image is amd64 only. |
| Dependencies | MongoDB (external). `apps/mongodb` exists in this repo (✅). |

## 2. Target layout

- `apps/nightscout/Dockerfile`
- `apps/nightscout/docker-bake.hcl`
- `apps/nightscout/settings.yaml`
- `apps/nightscout/start.sh`
- `apps/nightscout/container-test.yaml`

No `defaults/`, `etc/` or `health/` (no seed config is known). No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

```dockerfile
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5
```

Build and run on glibc Ubuntu through `python-node`. Do not `COPY --from=node:22-alpine`: the upstream image is musl (Alpine), which does not run on glibc Ubuntu. The Node version inside `python-node` is UNVERIFIED in this repo; check `node --version` in step 2. Node 20 or newer is required (engines). If the base has an older Node, stop and ask the user rather than installing Node from an unpinned source. Closest sibling: `apps/budge` (python-node, npm build in `/app`).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`, `ENV HOME=/config`.
2. Download the tag tarball into `/tmp`, verify the local SHA-256 pin, and extract into `/app/nightscout`:

   ```sh
   curl -fL -o /tmp/ns.tar.gz \
     "https://github.com/nightscout/cgm-remote-monitor/archive/refs/tags/v${VERSION}.tar.gz" && \
   echo "<sha256>  /tmp/ns.tar.gz" | sha256sum -c - && \
   mkdir -p /app/nightscout && \
   tar xzf /tmp/ns.tar.gz -C /app/nightscout --strip-components=1
   ```

   `<sha256>` is recorded in step 0 of section 11. The tag URL pattern follows `apps/budge`.
3. Install dependencies and build in the app directory, with caches in `/tmp`:

   ```sh
   cd /app/nightscout && \
   npm_config_cache=/tmp/npm npm ci --omit=optional --force && \
   npm prune --omit=dev --omit=optional && \
   rm -rf /tmp/*
   ```

   `--force` and `--omit=optional` follow the upstream builder. Check whether `--force` is still needed on v15.0.9 (UNVERIFIED).
4. License: `install -D /app/nightscout/LICENSE /usr/share/licenses/nightscout/LICENSE`.
5. `chown -R apps:apps /app/nightscout && chmod -R 755 /app/nightscout`.
6. Tail:

   ```dockerfile
   USER apps
   COPY --chmod=0755 . /

   ENV NODE_ENV=production
   EXPOSE 1337
   VOLUME /config
   WORKDIR /app/nightscout
   ```

   `VOLUME /config` is kept regardless (repo rule), even though the chart has no persistence.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "nightscout"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=nightscout/cgm-remote-monitor versioning=semver
  default = "15.0.9"
}

variable "LICENSE" {
  default = "AGPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/nightscout/cgm-remote-monitor"
}
```

Keep the four standard targets and the `default` group from `apps/budge/docker-bake.hcl` unchanged. The tag in the URL is `v${VERSION}`, so `VERSION` has no `v` prefix. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/nightscout/cgm-remote-monitor"
ports:
  - port: 1337
    protocol: tcp
    required: false
env:
  - name: API_SECRET
    default: ""
    required: true
  - name: MONGO_CONNECTION
    default: ""
    required: true
  - name: BASE_URL
    default: ""
    required: false
  - name: DISPLAY_UNITS
    default: ""
    required: false
  - name: ENABLE
    default: ""
    required: false
  - name: THEME
    default: "colors"
    required: false
  - name: TIME_FORMAT
    default: "24"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: false
dependencies:
  - name: mongodb
```

- `API_SECRET` and `MONGO_CONNECTION` are required, with no safe default. Rule: a `required: true` var needs a non-empty default or handling in `start.sh`. Resolve this in step 7 (section 7): `start.sh` must refuse to start with a clear message, not seed a secret.
- Keep only the variables verified in step 1 of section 11 (grep `process.env` in `lib/` at tag v15.0.9). Drop the rest. The `BG_*`, `INSECURE_USE_http` and `ENABLE` names come from the chart and are UNVERIFIED. Do not list them until confirmed.
- `TZ` is not verified for this app. Keep it only if the server reads it.
- `dependencies: - name: mongodb` matches the `apps/mongodb` directory (✅ exists, port 27017).

## 7. start.sh

```bash
#!/usr/bin/env bash

if [ -z "${API_SECRET:-}" ] || [ -z "${MONGO_CONNECTION:-}" ]; then
  echo "API_SECRET and MONGO_CONNECTION must be set" >&2
  exit 1
fi

cd /app/nightscout
exec node lib/server/server.js
```

- Exit with a message when a required secret is missing. This is the rule-compliant choice because the test runs with no env (see section 8).
- Do not print the secret. Do not put it in a file or a process argument.
- `exec` the final process so signals reach Node.
- Listen on all interfaces: confirm in the log (upstream `HOSTNAME` or `IP` env, UNVERIFIED) that the server binds `0.0.0.0`, not `localhost`.
- Idempotent: nothing to seed unless step 1 of section 11 finds persistent state.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '1337'
http:
- port: '1337'
  path: /
filePaths:
- /app/nightscout/lib/server/server.js
- /app/nightscout/node_modules
- /usr/share/licenses/nightscout/LICENSE
```

- The test runs with no env, so `start.sh` exits at the required-secret check. Decide whether that is the expected test outcome (see below).
- DB-dependency decision: the protocol exception applies only when all three criteria hold: (1) a hard `dependencies:` entry on a database (`mongodb`, yes); (2) the app will not start or fail health without the DB (likely, UNVERIFIED); (3) a sidecar DB cannot be wired into `container-test.yaml` with the available primitives (UNVERIFIED for `forgetool`). If all three hold, narrow the test to the process-starts and file checks above, and add the comment `# narrowed: requires external mongodb; full functional test not feasible in single-container suite`. If not, use the full `tcp`/`http` probes with a mongodb sidecar.
- Do not remove the `tcp` or `http` probe for 1337 (protocol coverage rule). Do not add a check that always passes.
- `timeoutSeconds: 120` is a starting value; no sibling in this batch sets it.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/opt/app` (upstream) | `/app/nightscout` (read only at runtime) |
| Generated keys (`post-generate-keys`, source tree) | UNVERIFIED path. Run the postinstall in the build stage, so nothing is generated at runtime. |
| Caches (npm) | `/tmp` only (`npm_config_cache=/tmp/npm` at build time) |
| Persistent app state | None in the chart; the data lives in MongoDB. |

- Chart forces UID 0, and `readOnlyRootFilesystem: false`. This image runs as `apps` and targets `--read-only --tmpfs /tmp`.
- Upstream runs as `node` (UID 1000). Our image runs as `apps`, so `/app/nightscout` must be readable (it is, `chmod -R 755`).
- If the postinstall writes keys into `node_modules` or the source tree at build time, the build must run as root before `USER apps`. Confirm in step 2.
- Privileged: not needed. Do not set it.

## 10. Risks, caveats and open questions

- Blocker: MongoDB is required. The app does not run without `MONGO_CONNECTION`. Users must run `apps/mongodb` or an external Mongo.
- Blocker: `API_SECRET` must be set before the first start. Without it the app either refuses to run or is insecure (draft and chart). Check which one v15.0.9 does (UNVERIFIED). Either way, `start.sh` refuses to start with the message in section 7.
- Blocker: the Hub image is a 2020 Travis test image, amd64 only. Build from source. Do not use it as `copy-from` (its upstream is Travis, not a release).
- Node 20 or newer is required. The Node version in `python-node` is UNVERIFIED. If the base is older, stop and ask.
- Env names from the chart are UNVERIFIED. `INSECURE_USE_http` looks like a spelling variant of the upstream variable; confirm before writing it into `settings.yaml`.
- The `--force` flag in `npm ci` is copied from upstream; check whether it is still needed.
- Arm64: the upstream build is multi-arch in principle, but untested here. Say so in the PR if not run.
- Security: AGPL-3.0. Keep the license file in `/usr/share/licenses/nightscout/`.

## 11. Build and test steps

```sh
cd apps/nightscout

# 0. Fetch the tag tarball into a fresh empty directory and pin its SHA-256
mkdir -p "$SCRATCH/ns" && curl -fL -o "$SCRATCH/ns/ns.tar.gz" \
  "https://github.com/nightscout/cgm-remote-monitor/archive/refs/tags/v15.0.9.tar.gz"
sha256sum "$SCRATCH/ns/ns.tar.gz"
# Read lib/ for process.env usage at that tag, and read the v15.0.9 Dockerfile and package.json engines.
# Do not run anything from the tarball.

# 1. Bake
docker buildx bake --print

# 2. Build (amd64 only; arm64 only if the failure is arm64-specific)
docker buildx bake --set image-local.platform=linux/amd64 image-local

# 3. Run with MongoDB and API_SECRET set (readiness with the DB), and once without them (must exit with the message)
docker run --rm -d --name nightscout-probe --read-only --tmpfs /tmp \
  -v nightscout-probe-config:/config -p 1337:1337 \
  -e API_SECRET="$(openssl rand -hex 24)" -e MONGO_CONNECTION="mongodb://user:pass@host:27017/db" \
  nightscout:15.0.9
docker logs -f nightscout-probe

# 4. Test
forgetool containers test --image nightscout:15.0.9 --config ./apps/nightscout/container-test.yaml

# Cleanup
docker rm -f nightscout-probe; docker volume rm nightscout-probe-config
```

- `$SCRATCH` is a placeholder for a fresh empty directory.
- The `MONGO_CONNECTION` value is a placeholder. Use a real `apps/mongodb` instance on the same Docker network for step 3, and record it.
- Readiness signal: UNVERIFIED. Expect a Nightscout startup line that names port 1337 (or the server's `listening` log). Record the exact line after the first run.
- Pass criteria: `.github/instructions/build-test-protocol.instructions.md`.

## 12. PR checklist

- Branch `feat/add-nightscout`, commit and PR title `feat(nightscout): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md` and keep its sections. Check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: contributions need a signed CLA (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it. The `license/cla` check shows the status.
- Say what was not tested: the full functional run with MongoDB (if not done), the env names not confirmed in upstream source, the Node version in `python-node`, arm64, and the no-secret exit path.
- `docker buildx bake --print` passes, and the bake `VERSION` equals the Dockerfile `ARG VERSION`.
