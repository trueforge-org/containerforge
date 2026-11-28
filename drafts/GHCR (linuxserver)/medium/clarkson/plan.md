# clarkson — implementation plan
> Source: ./draft.md · Target: apps/clarkson/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | v1.1.2 (published 2020-06-19). Latest tag. Tags: v1.1.2, v1.1.1, v1.1.0, v1.0.1, v1.0.0, v1.0.0-beta. Matches the chart image `ghcr.io/linuxserver/clarkson:1.1.2`. |
| Draft tag | Matches (1.1.2). |
| Renovate | `datasource=github-releases depName=linuxserver/Clarkson versioning=semver extractVersion=^v(?<version>.+)$` |
| License | MIT (GitHub API `license.spdx_id`, linuxserver/Clarkson). Note: this is the linuxserver fork, not the original project. |
| Source URL | https://github.com/linuxserver/Clarkson (last pushed 2021-08-12, stale upstream) |
| Download | Source tarball `https://github.com/linuxserver/Clarkson/archive/refs/tags/v1.1.2.tar.gz`. No release assets. Arch-independent source, built with npm on each arch. |
| Checksum source | UNVERIFIED: none published. The tarball is pinned by tag; verify by recording the sha256 at build time. |
| Upstream Dockerfile reviewed | linuxserver `docker-clarkson` @ a055394e1b15b406965902248118536959e54f1f: `FROM baseimage-alpine:3.12`; build deps build-base, curl, libsass-dev, nodejs-npm, tar, python2; runtime nodejs, nss, openjdk8-jre, sqlite-libs; extracts tarball to `/app/clarkson`; `chmod +x ./flyway/flyway`; `npm install`; `ng build --prod`; `npm run prune-angular2`; `npm prune --production`; `ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2`; no EXPOSE, VOLUME or USER.  |
| Real launch | linuxserver `root/etc/services.d/clarkson/run`: `cd /app/clarkson`, then `MYSQL_HOST=… MYSQL_USERNAME=… MYSQL_PASSWORD=… ENABLE_REGISTRATIONS=${ENABLE_REGISTRATIONS:-false} node clarkson.js` as `abc`. |
| Migration | linuxserver `root/etc/cont-init.d/30-migrate`: `./flyway/flyway -user=$MYSQL_USERNAME -password=$MYSQL_PASSWORD -schemas=clarkson -url=jdbc:mysql://$MYSQL_HOST migrate`, skipped when `TEST_RUN` is set. Flyway needs a Java runtime. |
| Upstream config (`server/config.js` @ v1.1.2) | `port: process.env.APP_PORT \|\| 3000`; `enableRegistration: process.env.ENABLE_REGISTRATIONS \|\| false`; `mysql.host/user/password` from `MYSQL_HOST`, `MYSQL_USERNAME`, `MYSQL_PASSWORD`; `jwtSecret: hash.random()` (new on every start). |
| Ports | 3000/tcp (default, from `APP_PORT`) |
| Env vars (real) | `APP_PORT`, `ENABLE_REGISTRATIONS`, `MYSQL_HOST`, `MYSQL_USERNAME`, `MYSQL_PASSWORD` |
| Data path | None under `/config` in upstream. The app persists everything in MariaDB. UNVERIFIED: no other runtime write path under `/app/clarkson`. |
| Dependencies | MariaDB (`apps/mariadb` exists in this repo, verified). Required before first start for the migration. |
| Node | Upstream builds with Node 8-era npm (python2, libsass). Current ubuntu base ships Node `26.13.1` (`apps/ubuntu/docker-bake.hcl`). UNVERIFIED: that the 2020 Angular build runs on Node 26. Top build risk. |
| arm64 | Source build, arch-independent. linuxserver arm64 image status UNVERIFIED (copy-from is `no`). |

## 2. Target layout

- `apps/clarkson/Dockerfile`
- `apps/clarkson/docker-bake.hcl`
- `apps/clarkson/settings.yaml`
- `apps/clarkson/container-test.yaml`
- `apps/clarkson/start.sh`

No `defaults/`, `etc/` or `health/` (no seed files; the app keeps no config on disk). No `root/`: the linuxserver s6 tree is replaced by `start.sh`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`.

Deviation from the draft: the draft says `python-node`. The repo rule in `.github/agents/container-porter.agent.md` maps "Node" to `ubuntu`, and sibling Node-only apps (`apps/pairdrop`, `apps/it-tools`) use ubuntu. `python-node` is reserved for images that need both Python and Node. Clarkson has no Python step, so `ubuntu` is used. The ubuntu base already ships Node 26.13.1 and npm.

Closest sibling: `apps/pairdrop` (Node on ubuntu, tarball + `npm ci --omit=dev`, `chown -R apps:apps /app`).

Java: flyway needs a JRE. Install it with apt in the runtime stage (see section 4). Alternative: the `java17` base, but that does not fit the Node rule above, so it is not used.

## 4. Dockerfile

Two stages on the same ubuntu base, so build tools do not reach the final image.

1. `FROM <ubuntu> AS build`, `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Build stage RUN:
   - `curl -fL https://github.com/linuxserver/Clarkson/archive/refs/tags/v${VERSION}.tar.gz | tar xz -C /app/clarkson --strip-components=1` (create `/app/clarkson` first; build stage only).
   - `cd /app/clarkson && npm install` then `npx ng build --prod` (or the `build` script), then `npm prune --production`. `python2`, `libsass-dev` and `build-base` are NOT needed on Node 26 if `node-sass` is replaced or not pulled. UNVERIFIED: whether v1.1.2's `package.json` deps compile on Node 26. If not, stop and record a blocker (section 10); do not patch the app's dependency set silently.
   - Keep `./flyway/` (it ships in the source tree) and `chmod +x ./flyway/flyway`.
   - Remove `/tmp/*` and npm caches; keep the output tree.
3. Final stage `FROM <ubuntu>` (same digest), `USER root`:
   - `apt-get update && apt-get install -y --no-install-recommends openjdk-21-jre-headless` (flyway runtime). UNVERIFIED: exact package name and version on ubuntu 26.04; pin it and check `docker buildx bake --print` output against `VERSION` only where it is the app version (the JRE is a toolchain, not the app, so no pin to `VERSION` is required).
   - `apt-get clean && rm -rf /var/lib/apt/lists/*`.
   - `mkdir -p /app/clarkson && COPY --from=build /app/clarkson/ /app/clarkson/`.
   - License: `COPY --from=build /app/clarkson/LICENSE /usr/share/licenses/clarkson/LICENSE`.
   - `chown -R apps:apps /app/clarkson && chmod -R 755 /app/clarkson` (build time only).
4. `ENV NODE_ENV=production`, `HOME=/tmp`, `NPM_CONFIG_CACHE=/tmp/.npm`.
5. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 3000
WORKDIR /app/clarkson
```

No `VOLUME` (Clarkson keeps no state on disk; the upstream linuxserver image had no VOLUME either). Confirm in the build check that no write to `/config` is needed.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "clarkson"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=linuxserver/Clarkson versioning=semver extractVersion=^v(?<version>.+)$
  default = "1.1.2"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/linuxserver/Clarkson"
}
```

Then the default group and the four standard targets copied from `apps/airsonic-advanced/docker-bake.hcl`. Note: the `VERSION` default (`1.1.2`) is passed to `ARG VERSION` as `v1.1.2` tag, so the Dockerfile prefixes `v`. Keep that prefix in the Dockerfile URL, not in the bake default. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/linuxserver/Clarkson"
ports:
  - port: 3000
    protocol: tcp
    required: true
env:
  - name: APP_PORT
    default: "3000"
    required: false
  - name: ENABLE_REGISTRATIONS
    default: "false"
    required: false
  - name: MYSQL_HOST
    default: "mariadb"
    required: true
  - name: MYSQL_USERNAME
    default: "clarkson"
    required: true
  - name: MYSQL_PASSWORD
    default: ""
    required: false
dependencies:
  - name: mariadb
```

- `MYSQL_HOST` default `mariadb` matches the sibling app name. It is a chosen default, not an upstream value; flag it in the PR.
- `MYSQL_PASSWORD` has no safe default. The rule requires a non-empty default or handling in `start.sh`. Open question (section 10): either generate a password in `start.sh` (not possible for an external DB user) or mark `required: false` and log a clear warning at start. The plan proposes the second. It must not exit: the container test runs with no env vars and still needs port 3000 open, so `start.sh` warns and continues (UNVERIFIED that `node clarkson.js` stays up with no reachable DB; if it exits, the test cannot probe 3000 and this needs a human decision).
- `TEST_RUN` is read by the upstream migration to skip flyway. It is not listed in `env:` because the plan does not expose it to users; the test path uses the DB exception (section 8).
- No `volumes:` entry: the app keeps no state on disk.

## 7. start.sh

```bash
#!/usr/bin/env bash

APP_PORT="${APP_PORT:-3000}"
ENABLE_REGISTRATIONS="${ENABLE_REGISTRATIONS:-false}"

MYSQL_HOST="${MYSQL_HOST:-mariadb}"
MYSQL_USERNAME="${MYSQL_USERNAME:-clarkson}"
if [[ -z "${MYSQL_PASSWORD}" ]]; then
  echo "clarkson: MYSQL_PASSWORD is not set, database access will fail" >&2
fi

cd /app/clarkson || exit 1

# migrate the schema on every start (flyway is idempotent)
./flyway/flyway \
  -user="${MYSQL_USERNAME}" \
  -password="${MYSQL_PASSWORD}" \
  -schemas=clarkson \
  -url="jdbc:mysql://${MYSQL_HOST}" \
  migrate || echo "clarkson: flyway migrate failed, is ${MYSQL_HOST} reachable? continuing" >&2

export APP_PORT ENABLE_REGISTRATIONS MYSQL_HOST MYSQL_USERNAME MYSQL_PASSWORD
exec node clarkson.js
```

- Idempotent: no seed files. Flyway migrates only pending versions.
- Writes nothing to `/app` at runtime. `HOME=/tmp` keeps any tool cache off `/config`.
- Passwords come from the environment on every start (rule: apply DB passwords each start). They are passed as env to flyway and node, not written to files. Flyway's `-password` puts it on the process list; mitigate with `FLYWAY_PASSWORD` env var instead of the CLI flag (flyway reads it from env). Use `FLYWAY_USER`, `FLYWAY_PASSWORD`, `FLYWAY_URL`, `FLYWAY_SCHEMAS` in the final version to keep the secret off `argv`. UNVERIFIED: that the bundled flyway version honours these env vars.
- Binds: Clarkson's `app.listen(config.port)` binds all interfaces by default (Node default), so `0.0.0.0` behaviour is good. UNVERIFIED: confirm at run time with `ss -ltn`.
- `exec node` hands PID 1 to node.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '3000'
http:
- port: '3000'
  path: /
filePaths:
- /app/clarkson/clarkson.js
- /app/clarkson/flyway/flyway
- /usr/share/licenses/clarkson/LICENSE
```

- Database-dependency exception applies (`dependencies: mariadb`, hard dependency, the app will not start without DB in the same network). Narrow the test to smoke assertions: `tcp 3000`, `filePaths` for the entry point and flyway binary. Add this comment above the narrowed assertions:
  `# narrowed: requires external mariadb; full functional test not feasible in single-container suite`
- The `http` probe on `/` is only valid if the app answers without a DB. UNVERIFIED. If it does not answer, drop the `http` probe, keeping `tcp 3000`, and record why. Do not replace with a no-op.
- All four DB-exception criteria must hold: hard dependency (yes), will not start without DB (to verify at run time), not feasible with a sidecar in the test primitives (yes). Record the verification result in the PR.
- `timeoutSeconds: 180` is a proposed value, tune to measured startup.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `HOME` / npm cache during build | Build stage only. Runtime `HOME=/tmp`. |
| Flyway temp files | `/tmp` (flyway writes to its own dir; UNVERIFIED, check at run time). |
| `/app/clarkson` | Read-only at runtime; built at build time. |
| `/config` | Not used. No `VOLUME`. |

Security expectations (draft): non-root yes (`USER apps`), read-only-rootfs yes (no runtime writes), privileged no, no extra persistence. Draft said "chart readOnlyRootFilesystem false": this plan runs read-only.

## 10. Risks, caveats and open questions

- Node version (top risk): the app dependency set is from 2020 (Angular build, node-sass era). Node 26 may not build it. If `npm install` or `ng build` fails for Node-version reasons, record it as a blocker. Do not change the dependency set or the Node version silently.
- Base image deviation: draft said `python-node`, plan uses `ubuntu` per the porter table (Node-only app). Record in the PR.
- Java: flyway needs a JRE. Package name and version on ubuntu 26.04 are UNVERIFIED; check with `apt-cache policy openjdk-21-jre-headless` in the build.
- Password on the command line: fixed by env vars (section 7), UNVERIFIED for the bundled flyway version.
- MariaDB required: the container will not be useful without it, and the test has no DB (section 8 exception).
- Stale upstream: last pushed 2021-08-12. Security posture is not maintained. Flag in PR.
- `MYSQL_PASSWORD` has no default (section 6): open question.
- arm64: untested. Build amd64 only unless the failure is arm64-specific.
- Blockers: none confirmed beyond the Node-version risk.

## 11. Build and test steps

```sh
cd apps/clarkson
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local

# no DB: expect a flyway warning (connection refused) and node still running, not a crash loop with a stack trace
docker run --rm --name clarkson-probe --read-only --tmpfs /tmp \
  -e MYSQL_HOST=127.0.0.1 -e MYSQL_USERNAME=probe -e MYSQL_PASSWORD=probe clarkson:1.1.2

# with DB: start mariadb from its image (apps/mariadb, built per its own plan) on a shared network,
# set MARIADB_ROOT_PASSWORD and a matching MYSQL_PASSWORD, then run clarkson on that network
docker network create clarkson-probe-net
docker run --rm -d --name mariadb-probe --network clarkson-probe-net \
  -e MARIADB_ROOT_PASSWORD=probe mariadb:<version-from-apps/mariadb>  # UNVERIFIED tag: copy from apps/mariadb/docker-bake.hcl
docker run --rm -d --name clarkson-probe --network clarkson-probe-net --read-only --tmpfs /tmp \
  -e MYSQL_HOST=mariadb-probe -e MYSQL_USERNAME=root -e MYSQL_PASSWORD=probe clarkson:1.1.2
docker logs -f clarkson-probe
docker rm -f clarkson-probe mariadb-probe; docker network rm clarkson-probe-net

forgetool containers test --image clarkson:1.1.2 --config ./apps/clarkson/container-test.yaml
```

- Expected readiness signal: the flyway migrate line completes, then the node process stays up and port 3000 accepts TCP. Upstream log line UNVERIFIED.
- Fail signals: migration `Connection refused` (no DB), `ENOENT` or `Cannot find module` (build output missing), node-sass or `gyp` errors (Node version, section 10).
- The `forgetool` run uses no env vars and no DB: it exercises the migrate-fail path only if the exception is not narrowed. Section 8 narrowing covers this.

## 12. PR checklist

- Branch: `feat/add-clarkson`, from `main`.
- Commit and PR title: `feat(clarkson): add new container`.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it. The `license/cla` check shows status.
- PR description: fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections and checkboxes, tick only what applies. Put `🤖 This PR is AI generated.` in the Notes section.
- Call out the base image deviation from the draft (`ubuntu` instead of `python-node`) and why.
- Untested, to state in the PR: arm64, the Node 26 build, the DB-dependent functional path (narrowed test), and any step not run.
- Do not check "Built container locally" unless `image-local` was built and the run passed.
