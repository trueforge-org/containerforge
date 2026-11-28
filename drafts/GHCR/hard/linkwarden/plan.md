# linkwarden — implementation plan
> Source: ./draft.md · Target: apps/linkwarden/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | v2.17.0 (latest release, published 2026-11-10). Matches the draft's image `ghcr.io/linkwarden/linkwarden:v2.17.0`. Source: https://api.github.com/repos/linkwarden/linkwarden/releases/latest and https://github.com/linkwarden/linkwarden/releases/tag/v2.17.0 |
| Renovate | `datasource=github-releases depName=linkwarden/linkwarden versioning=semver` (UNVERIFIED against upstream renovate config; tag is `v`-prefixed, so strip it for `VERSION`) |
| License | AGPL-3.0 (GitHub SPDX `AGPL-3.0`): https://api.github.com/repos/linkwarden/linkwarden |
| Source URL | https://github.com/linkwarden/linkwarden |
| Download | No prebuilt binary. Build from the source tag: `https://github.com/linkwarden/linkwarden/archive/refs/tags/v${VERSION}.tar.gz` (standard GitHub tag archive, UNVERIFIED that it was fetched in this run). |
| Per-arch | None published; compile per arch. Arm64 build is UNVERIFIED (Rust and Next.js builds are heavy, draft caveat). |
| Checksum source | None for the source archive. Pin by tag; record the tarball SHA256 at build time (UNVERIFIED how upstream publishes it). |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/linkwarden/linkwarden/v2.17.0/Dockerfile. Stage 1 `monolith-builder`: `FROM docker.io/rust:1.96-bookworm`, `ARG MONOLITH_VERSION=2.11.7`, `cargo install --locked` monolith. Stage 2 `app-builder`: `FROM node:22.23.4-bookworm-slim`, `WORKDIR /data`, `corepack enable`, `yarn workspaces focus` for `linkwarden`, `@linkwarden/web`, `@linkwarden/worker`, `yarn prisma:generate`, `yarn web:build`, prune to production deps. Stage 3 `main-app`: `FROM node:22.23.4-bookworm-slim`, `WORKDIR /data`, Playwright `chromium-headless-shell` into `/ms-playwright`, copies monolith to `/usr/local/bin/monolith`. `EXPOSE 3000`. `HEALTHCHECK` curl `http://127.0.0.1:3000/`. `CMD` runs `prisma migrate deploy` then starts web and worker via `concurrently`. No `USER`, no `VOLUME`, no `ENTRYPOINT`. |
| Ports | 3000 (EXPOSE, confirmed) |
| Env vars (confirmed in Dockerfile) | `NODE_ENV=production`, `PRISMA_HIDE_UPDATE_MESSAGE=1`, `PLAYWRIGHT_BROWSERS_PATH=/ms-playwright`, `COREPACK_ENABLE_DOWNLOAD_PROMPT=0`, plus build-only `YARN_HTTP_TIMEOUT`, `PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1` |
| Runtime env vars (DB, auth) | UNVERIFIED: the draft says the DB and auth secrets come only from secretKeyRef env vars, but the names (for example the database URL and the auth secret) were NOT confirmed from a fetched page. Confirm from https://docs.linkwarden.app/ before writing `settings.yaml`. Do not invent them. |
| Data and config write paths | `WORKDIR /data` (confirmed). Draft chart PVC: `/data/data` (chart pvc default). Upload and attachment paths UNVERIFIED. Next.js cache `apps/web/.next/cache` is created and made 777 by the Dockerfile (confirmed). |
| Dependencies | PostgreSQL: `apps/postgresql` exists in ContainerForge (confirmed by `ls apps`). Prisma migrations run at start (confirmed in CMD). |
| Health | `curl http://127.0.0.1:3000/` every 30 s (upstream HEALTHCHECK, confirmed). |

## 2. Target layout

- `apps/linkwarden/Dockerfile`
- `apps/linkwarden/docker-bake.hcl`
- `apps/linkwarden/settings.yaml`
- `apps/linkwarden/container-test.yaml`
- `apps/linkwarden/start.sh` (needed: runs `prisma migrate deploy`, then starts web and worker with `exec`; replaces the upstream `sh -c` CMD so PID 1 is the app process, and writes nothing to `/app`).
- `defaults/` only if a default config file is needed (not expected from the Dockerfile, UNVERIFIED).
- Never `root/`.
- No `DOWNSTREAM_CHANGES.md`: not used as a `FROM` base.

## 3. Base image

- Final and build stages: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`.
- Draft proposed `ghcr.io/trueforge-org/python-node` as the runtime image. That is a deviation: this app needs Node and no Python. The porter table maps Node-only apps to ubuntu, so the plan uses ubuntu, and Node 22 is added in the build stage. Decision for the user (section 10): switch to python-node only if it provides Node 22 and the tooling needed.
- Closest sibling: a Node/Next.js app in `apps/` (search `apps/*/Dockerfile` for `corepack` or `yarn` in the first build step; not done in this plan, UNVERIFIED pattern).

## 4. Dockerfile

Multi-stage, using the upstream pieces, adapted to ContainerForge:

1. Stage `monolith` (Rust): `FROM <ubuntu> AS monolith`, `ARG MONOLITH_VERSION=2.11.7`, install `cargo` and toolchain pinned from the apt archive or rustup (UNVERIFIED which; rustup needs network and a pinned version), `cargo install --locked monolith --version ${MONOLITH_VERSION}` into `/tmp/cargo` (`CARGO_HOME=/tmp/cargo`).
2. Stage `app` (Node): `FROM <ubuntu> AS app`, `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
3. Install Node 22 (pin the 22.x release; method UNVERIFIED: the apt archive may not carry it, and NodeSource or the official tarball need a checksum). Enable corepack (`corepack enable`), as upstream does.
4. Fetch source for `VERSION` into `/tmp/src` (`curl -fL https://github.com/linkwarden/linkwarden/archive/refs/tags/v${VERSION}.tar.gz | tar xz --strip-components=1`).
5. In `/tmp/src`: `corepack` install of the pinned yarn (version from `package.json` `packageManager`, UNVERIFIED), `yarn workspaces focus linkwarden @linkwarden/web @linkwarden/worker`, `yarn prisma:generate`, `yarn web:build`, then prune to production deps.
6. Stage `final`: `FROM <ubuntu>`, `USER root`. Install Node 22 (same method as step 3) and Playwright Chromium system libraries needed for `chromium-headless-shell` (install only what the build needs; the exact package list is UNVERIFIED and must be found by running the install). Install Playwright browser into `/ms-playwright` with `PLAYWRIGHT_BROWSERS_PATH=/ms-playwright` (upstream does this in the final stage, so keep it unless it can be dropped without breaking PDF/screenshot features, UNVERIFIED).
7. `COPY --from=monolith /tmp/cargo/bin/monolith /usr/local/bin/monolith`.
8. `COPY --from=app /tmp/src/ /app/linkwarden/` (includes node_modules, built `apps/web/.next`, prisma schema). Use `/app/linkwarden` as the app root, read-only at runtime.
9. Cache: `mkdir -p /tmp/next-cache` and symlink `/app/linkwarden/apps/web/.next/cache` to `/tmp/next-cache` (the upstream image makes `.next/cache` 777; the symlink keeps it writable without `/app` writes at runtime, because the link is made at build time). Verify the symlink survives `COPY --chmod`.
10. `chown -R apps:apps /app/linkwarden && chmod -R 755 /app/linkwarden`.
11. License: `COPY --from=app /tmp/src/LICENSE /usr/share/licenses/linkwarden/LICENSE` (UNVERIFIED that the file is named `LICENSE`; check the tree).
12. `ENV NODE_ENV=production PRISMA_HIDE_UPDATE_MESSAGE=1 PLAYWRIGHT_BROWSERS_PATH=/ms-playwright COREPACK_ENABLE_DOWNLOAD_PROMPT=0 NEXT_TELEMETRY_DISABLED=1 HOME=/tmp TZ=Etc/UTC` (`NEXT_TELEMETRY_DISABLED` is not in the upstream Dockerfile; it is a proposed addition, UNVERIFIED that it is needed).
13. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

WORKDIR /app/linkwarden
EXPOSE 3000
VOLUME /config
```

The `CMD`/`ENTRYPOINT` is `start.sh` (section 7), not an inline `sh -c`.

`apt-get` cleanup and `rm -rf /var/lib/apt/lists/*` after each install. Build-only tools (Rust, yarn caches, source tree beyond the runtime copy) must not reach the final stage.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "linkwarden"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=linkwarden/linkwarden versioning=semver
  default = "2.17.0"
}

variable "LICENSE" {
  default = "AGPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/linkwarden/linkwarden"
}
```

Plus the four standard targets and default group from `apps/adguardhome-sync/docker-bake.hcl`. Validate with `docker buildx bake --print`. The Dockerfile `ARG VERSION` must match.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/linkwarden/linkwarden"
ports:
  - port: 3000
    protocol: tcp
    required: true
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
  # Database and auth variables go here once confirmed from docs.linkwarden.app (UNVERIFIED names, required: true, defaults per start.sh).
volumes:
  - path: /config
    required: true
dependencies:
  - postgresql
```

- Ports: 3000 (confirmed).
- Env: only `TZ` is confirmed. The database connection and auth secret names are UNVERIFIED; the rule forbids invented env vars, so do not add them until confirmed. The draft says these come only from `secretKeyRef`, so they are `required: true` with no default (secrets must not be given a default).
- Volumes: `/config` required by ContainerForge rules, but the app's data path is `/data/data` in the chart. Decision in section 10: map the upload/data path to `/config`.
- Dependencies: `postgresql` (exists in ContainerForge as `apps/postgresql`, so the checkmark applies). Hard dependency.

## 7. start.sh

```bash
#!/usr/bin/env bash

# Required env from settings.yaml (names UNVERIFIED): fail clearly if the DB URL is missing.
mkdir -p /config/data
cd /app/linkwarden/packages/prisma 2>/dev/null || cd /app/linkwarden

# Migrations on every start (idempotent). Retry until the DB answers, bounded.
for i in $(seq 1 30); do
  npx prisma migrate deploy --schema ./schema.prisma && break
  sleep 2
done

cd /app/linkwarden
# Start web and worker; exec the supervisor so signals propagate.
exec npx concurrently -k "yarn workspace @linkwarden/web start" "yarn workspace @linkwarden/worker start"
```

Notes:
- Idempotent: `/config/data` is created only if missing. Nothing is written to `/app`.
- Upstream CMD is `sh -c` with `prisma migrate deploy` then `concurrently`; the plan keeps the same steps but in `start.sh`, with a bounded retry for database readiness (the draft says the first start fails if the DB is not ready). The exact `concurrently` command and `yarn workspace` script names must match upstream `package.json` (UNVERIFIED; read them from the v2.17.0 tree during build).
- `exec` on the supervisor (`concurrently`) so PID 1 receives signals. `-k` kills the other process if one exits.
- Secrets from env only; never written to files or the process list.
- Port 3000 is the web UI and is bound to all interfaces by Next.js default for `start` (UNVERIFIED: confirm with `HOSTNAME=0.0.0.0` or `-H 0.0.0.0`, set in `start.sh` if needed).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 300
tcp:
- port: '3000'
filePaths:
- /app/linkwarden/apps/web/.next/BUILD_ID
- /usr/local/bin/monolith
- /usr/share/licenses/linkwarden/LICENSE
```

- Port 3000 has a `tcp` probe (coverage rule).
- No `http` probe in the first version: the upstream health path is `/` (HEALTHCHECK), but it needs DB and auth. Add an `http` probe only once the DB narrowing in the protocol is applied.
- `timeoutSeconds: 300`: Next.js start plus Prisma migrations are slow (draft caveat). Use the sibling value if one exists.
- Database-dependent exception (protocol): linkwarden has a hard `dependencies:` entry on postgresql, does not start without it, and a single-container test cannot run it with the primitives used here. So the narrowing applies only if all three criteria hold. If the test passes only with narrowing, annotate the file with `# narrowed: requires external postgresql; full functional test not feasible in single-container suite`. Narrowed assertions are the tcp probe and file checks, never always-true checks.

## 9. Rootless and read-only-rootfs adaptations

| Upstream path | Remap |
| --- | --- |
| `/data` (WORKDIR in upstream, owned by root) | `/app/linkwarden` (read-only app code). Data goes to `/config/data` (proposed). |
| `apps/web/.next/cache` (777 in upstream) | Symlink to `/tmp/next-cache` made at build time, so runtime writes go to `/tmp`. |
| Prisma migrate writes (engine files, `node_modules/.prisma`) | Generated at build time; confirm migrate at runtime does not write into `/app` (UNVERIFIED; if it does, redirect with env or copy the engine to `/tmp` in `start.sh`). |
| Playwright browser (`/ms-playwright`) | Read-only install at build time; the browser needs writable `/tmp` for its profile (`HOME=/tmp`). |
| Upload and attachment storage (draft `/data/data`) | `/config/data` (proposed; confirm the env var that sets it, UNVERIFIED). |
| `monolith` binary | Copied to `/usr/local/bin`; read-only. |

Security expectations from the chart (draft): runs as root (`runAsUser 0`, `runAsGroup 0`), not read-only, no privileged flag. Target here: `USER apps`, read-only rootfs compatible. This is a change from the chart, so reconcile with the chart values when the chart is consumed.

## 10. Risks, caveats and open questions

- Base-image deviation: draft uses `python-node`; plan uses ubuntu with Node 22 added. User decision needed (section 3).
- Node 22 install method: not verified; the apt archive may not carry it. Needs a pinned source with checksum (UNVERIFIED).
- DB and auth env names: unverified. Blocker until confirmed from docs.linkwarden.app. `settings.yaml` and `start.sh` depend on them.
- PostgreSQL: must run before start. Prisma migrations run at start. The plan retries; a permanent DB failure should exit non-zero.
- Build cost: Rust monolith and Next.js build make arm64 builds from source long and heavy (draft caveat). Arm64 is untested.
- Playwright: needs Chromium system libraries; the exact package list is UNVERIFIED. This is the largest image-size driver. Ask the user whether PDF or screenshot features are required; if not, dropping Playwright is a scope change needing approval.
- Data path: chart uses `/data/data`; ContainerForge expects `/config`. Decision needed on the mapping, and the upstream env var that sets the data path (UNVERIFIED).
- Hard difficulty kept: several toolchains, a database, Prisma migrations at start, and a large Node stack.

## 11. Build and test steps

From `apps/linkwarden/`:

1. `docker buildx bake --print`.
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`. Expect a long build (Rust plus Next.js).
3. Start PostgreSQL first (`apps/postgresql` image, with a test password). Then probe linkwarden on a network with it, with an empty `/config`, read-only rootfs and tmpfs:
   `docker network create linkwarden-probe-net`, run `postgresql` on it, then
   `docker run --rm -d --name linkwarden-probe --network linkwarden-probe-net --read-only --tmpfs /tmp -v linkwarden-probe-config:/config -e <DB and auth vars> linkwarden:2.17.0`, then `docker logs -f linkwarden-probe`.
   Expected readiness: `prisma migrate deploy` completes, then the Next.js line that the server is ready on port 3000 (exact wording UNVERIFIED). Process still running.
   Cleanup: `docker rm -f linkwarden-probe postgresql-probe`, `docker volume rm linkwarden-probe-config`, `docker network rm linkwarden-probe-net`.
4. `forgetool containers test --image linkwarden:2.17.0 --config ./container-test.yaml`.
5. Narrowing: if the DB-dependent exception is used, annotate per the protocol. Never weaken the file checks.

## 12. PR checklist

- Branch: `feat/add-linkwarden`. Commit: `feat(linkwarden): add new container`.
- PR template: `.github/PULL_REQUEST_TEMPLATE.md`, keep sections and check only the boxes that apply.
- Notes section: `🤖 This PR is AI generated.`
- CLA: tell the user to sign at https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Downstream: not used as a `FROM` base, so no `DOWNSTREAM_CHANGES.md`.
- Honest untested list: not built or run in this plan; DB/auth env names, Node 22 install, Playwright packages, data path, and arm64 are untested until the steps above run.
