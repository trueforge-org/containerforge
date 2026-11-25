# peppermint — implementation plan
> Source: ./draft.md · Target: apps/peppermint/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | 0.5.5 is the latest GitHub release (published 2024-11-14T23:42:34Z, not prerelease). Source: https://api.github.com/repos/Peppermint-Lab/peppermint/releases/latest. The release has NO assets (no binary, no checksum file). Repo `pushed_at` is 2025-09-21, so `main` has moved on since the release. Decision needed (section 10). |
| Chart image | `docker.io/pepperlabs/peppermint:latest`. Docker Hub `latest` last pushed 2024-11-15T20:11:04Z, architectures amd64 and arm64. Stale, unversioned (https://hub.docker.com/v2/repositories/pepperlabs/peppermint/tags?page_size=5&ordering=last_updated). Do not copy from it. |
| Renovate | Source build pinned by commit: `// renovate: datasource=git-refs depName=https://github.com/Peppermint-Lab/peppermint currentValue=main` (precedent: `apps/tvheadend`; `apps/fenrus` is only a planned app, not in `apps/`). If the decision is the 0.5.5 tag instead, use `datasource=github-releases depName=Peppermint-Lab/peppermint versioning=loose`. |
| License | UNVERIFIED. GitHub API reports `NOASSERTION` (https://api.github.com/repos/Peppermint-Lab/peppermint). Read the repo `LICENSE` file and set SPDX before writing `docker-bake.hcl`. |
| Source URL | https://github.com/Peppermint-Lab/peppermint |
| Download | No prebuilt binary. Source archive `https://github.com/Peppermint-Lab/peppermint/archive/<commit-or-tag>.tar.gz`. Tag `0.5.5` archive URL is UNVERIFIED (the release exists, the tag not fetched). |
| Per-arch download | Same source archive for amd64 and arm64. Node builds run per arch under `docker buildx`, no arch-specific download. |
| Checksum source | None published. The archive is pinned by commit SHA (content-addressed), (same approach as the fenrus plan; `apps/fenrus` does not exist yet). |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/Peppermint-Lab/peppermint/ba6e2179f9409db76abeb9a3007a262160e24628/dockerfile (fetched). Builder: `FROM node:lts AS builder`, `apt-get install build-essential python3`, `npm i -g prisma`, `npm i -g typescript@latest --force`, `cd apps/api && npm install --production && npm i --save-dev @types/node && npm run build`, `cd apps/client && yarn install --production --ignore-scripts`, `yarn add --dev typescript @types/node`, `yarn build`. Runner: `FROM node:lts AS runner`, copies `apps/api`, `apps/client/.next/standalone`, `.next/static`, `public`, `ecosystem.config.js`; `EXPOSE 3000 5003`; `npm install -g pm2`; `CMD ["pm2-runtime", "ecosystem.config.js"]`. No `ENV`, `VOLUME`, `USER`, `ENTRYPOINT`, `WORKDIR` in the runner. Runs as root upstream. |
| Ports | 3000 (client UI) and 5003 (API), from upstream `EXPOSE`. |
| Env vars | UNVERIFIED. The upstream Dockerfile sets none. The real runtime variables (database URL, JWT or secret, client-to-API URL) must be read from `apps/api` and `apps/client` source at the chosen commit before `settings.yaml` is written. Do not guess. |
| Data paths | UNVERIFIED. Upstream has no `VOLUME`. Peppermint stores state in PostgreSQL, so no local persistence is expected (confirm in source). |
| Dependencies | PostgreSQL (hard, per draft; `apps/postgresql` exists). Prisma migrations must run before the API starts (draft, inferred). |
| Prisma binaries | The Dockerfile does not show whether Prisma downloads engines at build time. `npm install` scripts run without `--ignore-scripts` in `apps/api`, so the build needs network (UNVERIFIED which downloads happen). |

Draft says `runAsUser 0` and `readOnlyRootFilesystem: false` in the chart. Upstream confirms root and no `USER`, matching the chart.

## 2. Target layout

- `apps/peppermint/Dockerfile`
- `apps/peppermint/docker-bake.hcl`
- `apps/peppermint/settings.yaml`
- `apps/peppermint/container-test.yaml`
- `apps/peppermint/start.sh` (replaces upstream `pm2-runtime` CMD and handles migrations)
- `apps/peppermint/ecosystem.config.js` is NOT in the allow-list. Copy it through `app/` or `etc/` (include/.dockerignore allows `app/`, `etc/`, `defaults/`, `root/`), or write the pm2 config into `start.sh`. Decision in section 4.

No `defaults/`, `health/` needed. Never use `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

Runtime image: `ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5`

Rationale: the draft says python-node provides node, and `apps/changedetection` and `apps/budge` already use it for node work. Open conflict: `.github/agents/container-porter.agent.md` maps "Node" to `ghcr.io/trueforge-org/ubuntu`. Either choice needs a reviewer's decision (section 10). This plan follows the draft, and the Python part of the base is unused.

Foundation for build stage: the same python-node image, so the build and runtime share one userland and Node version. Closest siblings: `apps/changedetection` (python-node, multi-step build, `USER apps`, `COPY --chmod=0755 . /`) and `apps/budge`.

## 4. Dockerfile

1. Header: `ARG VERSION` (commit SHA or tag, must match bake default), `ARG TARGETARCH`.
2. Build stage `FROM <python-node> AS build` (or single stage if the runtime needs no extra copy; choose one and keep the multi-stage pattern if the builder writes large trees).
3. `USER root` for apt installs only:
   - `build-essential python3` (needed by native npm modules; the upstream builder installs them). Do NOT install them in the runtime stage if the final node_modules does not need them. Purge after build (changedetection pattern).
4. Fetch source, pinned:
   ```dockerfile
   RUN mkdir -p /app/peppermint && \
       curl -fsSL "https://github.com/Peppermint-Lab/peppermint/archive/${VERSION}.tar.gz" \
         | tar xz -C /app/peppermint --strip-components=1
   ```
   Verify nothing else (no published checksum). Only a commit SHA gives content addressing.
5. Install and build, following the upstream builder steps in the same order, with caches in `/tmp`:
   - `ENV NPM_CONFIG_CACHE=/tmp/npm YARN_CACHE_FOLDER=/tmp/yarn PRISMA_ENGINES_CHECKSUM_IGNORE_MISSING=1` (names verify against the Prisma version in use; UNVERIFIED).
   - `cd /app/peppermint/apps/api && npm install && npx prisma generate && npm run build`
   - `cd /app/peppermint/apps/client && yarn install --ignore-scripts && yarn build`
   - Drop `npm i -g typescript@latest --force` unless the build needs it (upstream forces it; verify).
6. Runtime: install `pm2` pinned (`npm install -g pm2@<version>`, renovate `datasource=npm`), used only to run the two processes. `PM2_HOME=/tmp/.pm2`.
7. Copy artifacts into `/app/peppermint`, then `chown -R root:root /app && chmod -R 755 /app` (read-only at runtime). Ship license to `/usr/share/licenses/peppermint/LICENSE` (source file name UNVERIFIED).
8. Tail:
   ```dockerfile
   ENV HOME=/config PM2_HOME=/tmp/.pm2 NPM_CONFIG_CACHE=/tmp/npm
   USER apps
   COPY --chmod=0755 . /
   EXPOSE 3000 5003
   WORKDIR /app/peppermint
   ```
   `VOLUME /config` only if the app persists files (none expected; see section 6).

## 5. docker-bake.hcl

Same shape as `apps/adguardhome-sync/docker-bake.hcl` (`apps/pgadmin` does not exist yet; four standard targets, default group, OCI labels). Key values:

```hcl
variable "APP" { default = "peppermint" }
variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/Peppermint-Lab/peppermint currentValue=main
  default = "<full commit SHA>"
}
variable "LICENSE" { default = "<confirmed SPDX>" }
variable "SOURCE" { default = "https://github.com/Peppermint-Lab/peppermint" }
```

`VERSION` must be a commit SHA chosen in section 10, not `main`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/Peppermint-Lab/peppermint"
ports:
  - port: 3000
    protocol: tcp
    required: true
  - port: 5003
    protocol: tcp
    required: true
env:
  # UNVERIFIED: database URL, secret and API URL names and defaults must be read from source.
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes: []
dependencies:
  - postgresql
```

- Ports: 3000 and 5003 (upstream `EXPOSE`; probes are in section 8).
- `dependencies: postgresql` (exists in apps/, hard dependency per draft).
- Env list is intentionally incomplete until source confirms names. Do not invent variables (settings rule).
- `volumes`: none. `/config` is omitted only if no local state is written (confirm). If `/config` is needed for uploads, add it with `required: true`.

## 7. start.sh

Idempotent. Runs migrations, then starts both services with `exec`.

```bash
#!/usr/bin/env bash
set -euo pipefail

cd /app/peppermint/apps/api
# Prisma migrations before the API starts (draft: inferred). Requires DATABASE_URL.
npx prisma migrate deploy

cd /app/peppermint
exec pm2-runtime /app/peppermint/ecosystem.config.js
```

- Migration step waits for PostgreSQL. Retry loop with a timeout, logged. Do not loop forever.
- PostgreSQL password and URL are applied from env on every start (start-script rule). Never write secrets to files.
- `pm2-runtime` is PID 1 handoff via `exec`. It runs two processes (API 5003, client 3000) under one supervisor (draft caveat).
- Bind both to `0.0.0.0`: Next.js and API defaults may bind localhost. Check `apps/client` `next start -H` and the API listen call (UNVERIFIED). Set `HOSTNAME=0.0.0.0` if Next reads it.
- The `ecosystem.config.js` path must be the one copied in section 2.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

# narrowed: requires external postgresql; full functional test not feasible in single-container suite
timeoutSeconds: 180
tcp:
- port: '3000'
- port: '5003'
http:
- port: '3000'
  path: /
filePaths:
- /app/peppermint/apps/api
- /app/peppermint/apps/client/.next/standalone
- /usr/share/licenses/peppermint/LICENSE
```

- Every port in settings has a probe (tcp for both; http on the client UI).
- The DB-dependency narrowing applies only if all three protocol criteria hold: hard dependency (yes), will not start without DB (to verify in the run step: if the API starts without DB, narrowing is not justified and full tests are needed), not feasible with a sidecar in `container-test.yaml` (verify).
- Test runs without env vars, so code that needs `DATABASE_URL` is not covered. Add the migration file to `filePaths` if needed.

## 9. Rootless and read-only-rootfs adaptations

| Upstream behavior | ContainerForge target |
| --- | --- |
| Runs as root (no `USER`) | `USER apps`. |
| pm2 writes `~/.pm2` (logs, pid, dump) | `PM2_HOME=/tmp/.pm2`; logs to `/tmp` (ephemeral). |
| npm and yarn caches in `$HOME` | `NPM_CONFIG_CACHE=/tmp/npm`, `YARN_CACHE_FOLDER=/tmp/yarn`. |
| Prisma engine write at runtime (UNVERIFIED) | Generate at build time. No runtime writes to `/app`. |
| Next.js `.next/cache` (UNVERIFIED) | Set `NEXT_CACHE_DIR` or `NEXT_TELEMETRY_DISABLED=1` and point cache at `/tmp` if Next writes there. |
| Ports 3000 and 5003 | Unprivileged, no change. |
| `readOnlyRootFilesystem: false` in chart | Target read-only-rootfs compatible. |

## 10. Risks, caveats and open questions

- Version choice (decision needed): the only GitHub release (0.5.5, 2024-11-14) has no binaries. The repo has moved on (pushed 2025-09-21). This plan proposes pinning a commit SHA on `main` (a planned approach, see the fenrus plan; `apps/tvheadend` pins a branch). Reviewer must confirm the commit is one the upstream considers stable.
- Chart image is stale: `pepperlabs/peppermint:latest` was last pushed 2024-11-15. The ContainerForge image will not match it. Document that in the PR.
- Base choice conflict: python-node (draft and sibling pattern) vs ubuntu (porter table for Node). Reviewer decides; this plan assumes python-node.
- Runtime env vars are unknown (section 1). Blocking: `settings.yaml` and `start.sh` cannot be finished until the source is read at the chosen commit.
- License is `NOASSERTION` on GitHub. Confirm before `LICENSE` is set.
- Two listeners under pm2, plus migrations before start, is a larger runtime surface than most siblings. Keep `start.sh` simple and log the migration result.
- Prisma and npm install scripts fetch from the network at build time. Builds need internet (draft caveat, confirmed for npm scripts; Prisma specifics UNVERIFIED).
- Blockers: no arch-specific binary, no GPU, no privileged need. None fatal found.

## 11. Build and test steps

From `apps/peppermint/`:

1. `docker buildx bake --print` (must exit 0).
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. Start a postgresql container (from `apps/postgresql` image) on a shared network, then run peppermint on `--read-only --tmpfs /tmp` with a fresh `/config` volume if one is declared, and the DB env vars from section 6:
   ```sh
   docker network create peppermint-probe-net
   docker run --rm -d --name peppermint-probe-db --network peppermint-probe-net -e ... ghcr.io/trueforge-org/postgresql:<ver>
   docker run --rm -d --name peppermint-probe --network peppermint-probe-net --read-only --tmpfs /tmp -e DATABASE_URL=... peppermint:<version>
   docker logs -f peppermint-probe
   ```
   Expected readiness: migrations complete with no error, pm2 shows both processes online, and the logs contain "listening" or the Next.js "ready" line (UNVERIFIED wording).
4. Cleanup: `docker rm -f peppermint-probe peppermint-probe-db; docker network rm peppermint-probe-net`.
5. `forgetool containers test --image peppermint:<version> --config ./container-test.yaml`.
6. Note arm64 is built only if amd64 fails.

## 12. PR checklist

- Branch `feat/add-peppermint`, commit `feat(peppermint): add new container`, PR title matches.
- PR body from `.github/PULL_REQUEST_TEMPLATE.md`, checkboxes only where true.
- Notes section contains `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it.
- Say what was not tested (arm64, full functional test if DB-narrowed, Prisma migrations against a real DB if not run).
- Mention that the chart image (`pepperlabs/peppermint:latest`, 2024) is replaced by a source build.
- Check "Built container locally" only after the step 2 build succeeds.
